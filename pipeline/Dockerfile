# Copyright (c) 2025-2026 Log10x, Inc.
# SPDX-License-Identifier: Apache-2.0

FROM --platform=${BUILDPLATFORM:-linux/amd64} registry.access.redhat.com/ubi8/ubi:8.10 AS tenx-builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
ARG FLAVOR="cloud"

# Install curl, needed for 10x install script
#
RUN dnf install -y curl

# Install 10x
#
RUN curl https://raw.githubusercontent.com/log-10x/pipeline-releases/main/install.sh | bash -s -- --version ${VERSION} --flavor ${FLAVOR} --no-env-setup

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
ARG FLAVOR="cloud"

# Install binutils (strings), needed for 10x 'compile'
# Install shadow-utils, needed for useradd
#
RUN microdnf install -y binutils shadow-utils

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
ENV TENX_HOME=/opt/tenx-${FLAVOR}
ENV TENX_BIN=/opt/tenx-${FLAVOR}/bin/tenx-${FLAVOR}
ENV TENX_MODULES=/opt/tenx-${FLAVOR}/lib/app/modules
ENV TENX_CONFIG=/etc/tenx/config
ENV TENX_SYMBOLS_PATH=/etc/tenx/symbols

# Set 10x logger to console.
#
ENV TENX_LOG_APPENDER=tenxConsoleAppender

# Copy 10x from builder
#
COPY --from=tenx-builder $TENX_SYMBOLS_PATH $TENX_SYMBOLS_PATH
COPY --from=tenx-builder $TENX_CONFIG $TENX_CONFIG
COPY --from=tenx-builder $TENX_HOME $TENX_HOME

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
