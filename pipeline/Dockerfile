# Copyright (c) 2025-2026 Log10x, Inc.
# SPDX-License-Identifier: Apache-2.0

FROM --platform=${BUILDPLATFORM:-linux/amd64} registry.access.redhat.com/ubi8/ubi:8.10 AS tenx-builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
# The flavor FLAG passed to install.sh.
ARG FLAVOR="compiler"

# Install curl, needed for 10x install script
#
RUN dnf install -y curl

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

FROM --platform=${BUILDPLATFORM:-linux/amd64} registry.access.redhat.com/ubi8/ubi-minimal:8.10

# OCI Image Labels
LABEL org.opencontainers.image.title="Log10x Pipeline"
LABEL org.opencontainers.image.description="Log10x observability runtime for log/trace optimization"
LABEL org.opencontainers.image.vendor="Log10x, Inc."
LABEL org.opencontainers.image.licenses="LicenseRef-Log10x-Proprietary"
LABEL org.opencontainers.image.documentation="https://doc.log10x.com"
LABEL org.opencontainers.image.source="https://github.com/log-10x/docker-images"
LABEL com.log10x.license.required="true"
LABEL com.log10x.license.url="https://log10x.com/pricing"

ARG TARGETPLATFORM
ARG BUILDPLATFORM
# PACKAGE_ID is the install prefix and binary name that the compiler flavor's
# .deb/.rpm creates. It is NOT the flavor flag above, and it does not change
# with the flavor rename -- see pipeline-releases/FLAVORS.md. Change these two
# only together.
ARG PACKAGE_ID="cloud"
ARG LICENSE_JWT

# Install binutils (strings) + file (executable scanner), needed for 10x 'compile'
# Install shadow-utils, needed for useradd
#
RUN microdnf install -y binutils file shadow-utils

# Install python3, needed for 10x 'compile'
#
RUN microdnf install -y python39 python39-pip && \
    python3 -m pip install --no-cache-dir --upgrade pip setuptools urllib3 && \
    rpm -e --nodeps python39-pip python39-pip-wheel \
                    python39-setuptools python39-setuptools-wheel 2>/dev/null; true

# Install fluent-bit, used for forwarding data from 10x pipeline
# to any supported destination, needed for certain 'run' configurations
#
COPY ./fluent-bit.repo /etc/yum.repos.d/fluent-bit.repo
RUN microdnf install -y fluent-bit

# Clean up the microdnf cache to reduce image size
#
RUN microdnf clean all

# Make sure path for log file exists and is accessible to all users.
# This allows changing TENX_LOG_APPENDER to tenxFileAppender if desired
#
RUN mkdir -p /var/log/tenx && chmod 777 /var/log/tenx

# Manually setting up 10x environment variables
#
ENV TENX_HOME=/opt/tenx-${PACKAGE_ID}
ENV TENX_BIN=/opt/tenx-${PACKAGE_ID}/bin/tenx-${PACKAGE_ID}
ENV TENX_MODULES=/opt/tenx-${PACKAGE_ID}/lib/app/modules
ENV TENX_CONFIG=/etc/tenx/config
ENV TENX_SYMBOLS_PATH=/etc/tenx/symbols

# Set 10x logger to console.
#
ENV TENX_LOG_APPENDER=tenxConsoleAppender

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

# Give permissions to the config
#
RUN chmod -R 777 $TENX_CONFIG

# Create tenxuser user and run from their home directory
RUN useradd -m -u 1000 tenxuser
USER tenxuser
WORKDIR /home/tenxuser

ENTRYPOINT [ "sh", "-c", "exec $TENX_BIN \"${@}\"", "--" ]

# Default run sample
#
CMD [ "@apps/dev" ]
