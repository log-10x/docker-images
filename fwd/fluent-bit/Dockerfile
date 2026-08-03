# Copyright (c) 2025-2026 Log10x, Inc.
# SPDX-License-Identifier: Apache-2.0
#
# 10x builder
#
FROM --platform=${BUILDPLATFORM:-linux/amd64} debian:bookworm-slim AS tenx-builder

# Created here because the fluent-bit runtime stage has no coreutils (see below).
RUN mkdir -p /var/log/tenx && chmod 777 /var/log/tenx

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
# The token is a BuildKit secret, not a build-arg: these images are public and a
# build-arg would be visible in `docker history` forever. It raises install.sh's
# GitHub API limit, which is 60 requests/hour PER IP unauthenticated. The publish
# fans out ~10 parallel builds on shared runner IPs, exhausts the quota, and the
# builds fail with HTTP 403. Optional: absent, the install still works, it is just
# rate-limited.
RUN --mount=type=secret,id=gh_token \
    TENX_GITHUB_TOKEN="$(cat /run/secrets/gh_token 2>/dev/null || true)" \
    sh -c 'curl https://raw.githubusercontent.com/log-10x/pipeline-releases/main/install.sh | TENX_GITHUB_TOKEN="$TENX_GITHUB_TOKEN" bash -s -- --version ${VERSION} --flavor ${FLAVOR} --no-env-setup'


# Fluent-bit image
#
FROM --platform=${BUILDPLATFORM:-linux/amd64} fluent/fluent-bit:4.1.1

# OCI Image Labels - Multi-license (Apache 2.0 + Log10x Proprietary)
LABEL org.opencontainers.image.title="Log10x Fluent Bit"
LABEL org.opencontainers.image.description="Fluent Bit with Log10x edge processing"
LABEL org.opencontainers.image.vendor="Log10x, Inc."
LABEL org.opencontainers.image.licenses="Apache-2.0 AND LicenseRef-Log10x-Proprietary"
LABEL org.opencontainers.image.base.name="fluent/fluent-bit:4.1.1"
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

# Copying a minimal shell from the builder
#
# This is needed because 'tenx.lua' invokes the 10x pipeline runable by
# calling io.popen, which relies on a /bin/sh -c call to work
#
# For more info, see:
# https://man7.org/linux/man-pages/man3/popen.3.html
# https://www.lua.org/manual/5.4/manual.html#pdf-io.popen
#
COPY --from=tenx-builder /bin/dash /bin/sh

# Copy 10x from builder, forcing root ownership.
#
# --chown=0:0 is load-bearing. The release tarballs on
# log-10x/pipeline-releases are packed by a GitHub Actions runner, so every
# member carries uid/gid 1001 ("runner"), install.sh unpacks them with
# `tar -xzf` as root, and GNU tar restores the archived owner when it runs as
# root. A plain `COPY --from` then preserves 1001:1001 into the final image,
# which means the engine binary and its config are owned by whatever local
# account happens to hold uid 1001. Filebeat's strict-perms check rejects that
# outright; see fwd/filebeat/Dockerfile for the measured failure.
#
COPY --chown=0:0 --from=tenx-builder $TENX_SYMBOLS_PATH $TENX_SYMBOLS_PATH
COPY --chown=0:0 --from=tenx-builder $TENX_CONFIG $TENX_CONFIG
COPY --chown=0:0 --from=tenx-builder $TENX_HOME $TENX_HOME

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
# fluent/fluent-bit has no coreutils, so `mkdir` does not exist in this stage:
# `RUN mkdir -p /var/log/tenx` fails with `/bin/sh: 1: mkdir: not found`, which is
# why no native fluent-bit image has ever built. Create it in the builder, which is
# debian-based, and copy the directory in.
COPY --from=tenx-builder --chmod=777 /var/log/tenx /var/log/tenx
ENV TENX_LOG_APPENDER=tenxConsoleAppender
