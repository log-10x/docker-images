# Copyright (c) 2025-2026 Log10x, Inc.
# SPDX-License-Identifier: Apache-2.0

FROM --platform=${BUILDPLATFORM:-linux/amd64} debian:bookworm-slim AS tenx-builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

# Install curl, needed for 10x install script
#
RUN apt-get update && apt-get install -y curl

# Install the 10x runtime: the native binary (reporter, receiver, retriever,
# MCP, CLI). 'runtime' is the flavor flag; the install prefix it produces is
# /opt/tenx-edge, named for the package id -- see pipeline-releases/FLAVORS.md.
#
RUN curl https://raw.githubusercontent.com/log-10x/pipeline-releases/main/install.sh | bash -s -- --version ${VERSION} --flavor runtime --no-env-setup

FROM --platform=${BUILDPLATFORM:-linux/amd64} debian:bookworm-slim

# OCI Image Labels
LABEL org.opencontainers.image.title="Log10x Edge"
LABEL org.opencontainers.image.description="Log10x native edge runtime for log/trace optimization"
LABEL org.opencontainers.image.vendor="Log10x, Inc."
LABEL org.opencontainers.image.licenses="LicenseRef-Log10x-Proprietary"
LABEL org.opencontainers.image.documentation="https://doc.log10x.com"
LABEL org.opencontainers.image.source="https://github.com/log-10x/docker-images"
LABEL com.log10x.license.required="true"
LABEL com.log10x.license.url="https://log10x.com/pricing"

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG LICENSE_JWT

# Make sure path for log file exists and is accessible to all users.
# This allows changing TENX_LOG_APPENDER to tenxFileAppender if desired
#
RUN mkdir -p /var/log/tenx && chmod 777 /var/log/tenx

# Manually setting up 10x environment variables
#
ENV TENX_HOME=/opt/tenx-edge
ENV TENX_BIN=/opt/tenx-edge/bin/tenx-edge
ENV TENX_MODULES=/opt/tenx-edge/lib/app/modules
ENV TENX_CONFIG=/etc/tenx/config
ENV TENX_SYMBOLS_PATH=/etc/tenx/symbols
ENV TENX_LICENSE_KEY=${LICENSE_JWT}

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
