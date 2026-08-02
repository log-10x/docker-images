# Copyright (c) 2025-2026 Log10x, Inc.
# SPDX-License-Identifier: Apache-2.0
#
# 10x builder
#
FROM --platform=${BUILDPLATFORM:-linux/amd64} ubuntu:20.04 AS tenx-builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
ARG FLAVOR="runtime"

# Only the runtime flavor is supported for forwarder builds. The compiler
# flavor is a .deb/.rpm with a bundled JRE and installs to /opt/tenx-cloud,
# which is not the prefix this image bakes into TENX_HOME below.
#
# 'native' is the old spelling of 'runtime' and still resolves; 'edge' named
# the retired jpackage JIT build and is rejected by install.sh itself.
RUN VALIDATE_FLAVOR=$(echo "${FLAVOR}" | tr '[:upper:]' '[:lower:]') && \
    if [ "$VALIDATE_FLAVOR" != "runtime" ] && [ "$VALIDATE_FLAVOR" != "native" ]; then \
    echo "Invalid flavor: ${FLAVOR}. Allowed values are: Runtime" >&2; \
    exit 1; \
fi

# Install curl, needed for 10x install script
#
RUN apt-get update && apt-get install -y curl

# Install 10x
#
RUN curl https://raw.githubusercontent.com/log-10x/pipeline-releases/main/install.sh | bash -s -- --version ${VERSION} --flavor ${FLAVOR} --no-env-setup


# Filebeat image
FROM --platform=${BUILDPLATFORM:-linux/amd64} docker.elastic.co/beats/filebeat:8.5.1

# OCI Image Labels - Multi-license (Elastic License + Log10x Proprietary)
LABEL org.opencontainers.image.title="Log10x Filebeat"
LABEL org.opencontainers.image.description="Filebeat with Log10x edge processing"
LABEL org.opencontainers.image.vendor="Log10x, Inc."
LABEL org.opencontainers.image.licenses="Elastic-2.0 AND LicenseRef-Log10x-Proprietary"
LABEL org.opencontainers.image.base.name="docker.elastic.co/beats/filebeat:8.5.1"
LABEL org.opencontainers.image.documentation="https://doc.log10x.com"
LABEL org.opencontainers.image.source="https://github.com/log-10x/docker-images"
LABEL com.log10x.license.required="true"
LABEL com.log10x.license.url="https://log10x.com/pricing"

ARG LICENSE_JWT

# Manually setting up 10x environment variables
#
# /opt/tenx-edge is the install prefix for the RUNTIME flavor. The prefix is
# named for the package id, not the flavor, and it does not change with the
# rename -- see pipeline-releases/FLAVORS.md.
ENV TENX_HOME=/opt/tenx-edge
ENV TENX_BIN=/opt/tenx-edge/bin/tenx-edge
ENV TENX_MODULES=/opt/tenx-edge/lib/app/modules
ENV TENX_SYMBOLS_PATH=/etc/tenx/symbols
ENV TENX_LICENSE_KEY=${LICENSE_JWT}
#
# Setting up the path to config files
# This can be overriden by deployment envs like k8s, when creating user config
#
ENV TENX_CONFIG=/etc/tenx/config
#
# Running 10x with filebeat receiver launch configuration
# This can be overriden by deployment envs like k8s, when creating user config
#
ENV TENX_RUN_ARGS="@run/input/forwarder/filebeat @apps/receiver"

# Switch to root in order to be able to perform the installation and modification
#
USER root

# Modify the image entrypoint file, to run filebeat with a pipe into 10x executable
#
RUN sed -i '0,/exec filebeat "$@"/s//exec filebeat "$@" 2\>\&1 | $TENX_BIN run $TENX_RUN_ARGS/' /usr/local/bin/docker-entrypoint

# Copy 10x from builder, forcing root ownership.
#
# --chown=0:0 is load-bearing. The release tarballs on
# log-10x/pipeline-releases are packed by a GitHub Actions runner, so every
# member carries uid/gid 1001 ("runner"):
#
#   $ tar --numeric-owner -tvzf tenx-modules-1.1.38.tar.gz | head -1
#   -rw-r--r--  0 1001 1001  1074 LICENSE
#
# install.sh unpacks them with `tar -xzf` as root, and GNU tar restores the
# archived owner when it runs as root, so the whole installed tree lands as
# 1001:1001. A plain `COPY --from` preserves that into the final image.
#
# Filebeat then refuses to load its own config files, because libbeat's
# strict-perms check requires every config file to be owned by root or by the
# effective uid. Measured on this image built without --chown, run as uid 0,
# which is what the chart uses (daemonset.securityContext.runAsUser: 0):
#
#   Exiting: Failed to start crawler: starting input failed: error while
#   initializing input: failed in processor.javascript: config file
#   (".../input/forwarder/filebeat/script/tenx-receive.js") must be owned by
#   the user identifier (uid=0) or root
#   exit 1
#
# The chart loads two files out of this tree: the script processor above and
# `conf/tenxNix.yml` via filebeat.config.inputs, so both trip the check.
#
# uid 0 is the right owner rather than 1000/filebeat: libbeat accepts a
# root-owned config for ANY effective uid, so this works whether the pod runs
# as root or as the image's default filebeat user. The alternative fix,
# passing -strict.perms=false in the chart, disables a security check to paper
# over our own packaging, and would leave the engine binary owned by whatever
# local account happens to hold uid 1001.
#
COPY --chown=0:0 --from=tenx-builder $TENX_SYMBOLS_PATH $TENX_SYMBOLS_PATH
COPY --chown=0:0 --from=tenx-builder $TENX_CONFIG $TENX_CONFIG
COPY --chown=0:0 --from=tenx-builder $TENX_HOME $TENX_HOME

# Switch back tothe filebeat user, same as original image
#
# Create the engine's log directory and default its logs to stdout.
#
# Without this the image CANNOT START. The engine's default log4j2 appender is
# tenxFileAppender at /var/log/tenx/tenx.log; the directory does not exist, and
# for filebeat the image ends on a non-root USER that cannot create it. The
# RollingFileAppender then fails to construct and that failure is FATAL:
#
#   Caused by: java.io.IOException: Could not create directory /var/log/tenx
#   -> could not launch pipeline: 'run'
#
# Measured on the published log10x/filebeat-10x:1.1.25-native, same image, same
# config, same license, only the user differing:
#
#   as USER filebeat (shipped default)   launch fails
#   as root                              0 launch failures
#
# edge-10x has had both lines since it was written, which is why it works. The
# forwarders never got them.
#
# The console appender is also the right default for a container regardless:
# with the file appender only the startup banner reaches stdout, so `kubectl
# logs` shows a healthy-looking pod while every WARN, ERROR and stack trace goes
# to a file nobody reads. Set TENX_LOG_APPENDER=tenxFileAppender to opt back in.
RUN mkdir -p /var/log/tenx && chmod 777 /var/log/tenx
ENV TENX_LOG_APPENDER=tenxConsoleAppender

# Second launch blocker, same shape as the one above, one layer deeper.
#
# The filebeat module's log4j2.yaml declares a filebeatRollingFile appender that
# replays Filebeat's own log lines to wherever Filebeat would have written them:
#
#   fileName: "${env:filebeatPath:-${env:filebeatLogsPath}}..."
#
# log4j2 does NOT recurse into a `:-` default, so with both variables unset the
# name resolves to the literal string, and log4j2 builds appenders eagerly --
# a threshold filter that would disable this one does not stop construction:
#
#   Could not create directory /usr/share/filebeat/${env:filebeatLogsPath}
#   -> could not launch pipeline: 'run'
#
# The module intends these to come from Filebeat's startup banner, parsed off
# the pipe by the `match` extractor in stream.yaml. Measured: the banner does
# reach the engine (teed the pipe and found it on line 1, and the module's regex
# matches it), yet the value never lands here -- these lookups read
# System.getenv, which the engine cannot populate for its own process.
#
# So the variable has to be set in the environment, and /usr/share/filebeat/logs
# is exactly the Logs path Filebeat reports in that banner. It already exists in
# the base image and is group-writable by uid 1000. Override it if Filebeat is
# reconfigured with a different logging.files.path.
#
# Verified on log10x/filebeat-10x:1.1.25-native with the documented Receiver
# config, unset vs set, nothing else differing:
#
#   filebeatLogsPath unset   2 launch failures, 0 events shipped
#   filebeatLogsPath set     0 launch failures, events shipped to the destination
ENV filebeatLogsPath=/usr/share/filebeat/logs

USER filebeat
