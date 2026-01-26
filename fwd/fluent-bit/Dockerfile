# Copyright (c) 2025-2026 Log10x, Inc.
# SPDX-License-Identifier: Apache-2.0
#
# 10x builder
#
FROM --platform=${BUILDPLATFORM:-linux/amd64} debian:bookworm-slim AS tenx-builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
ARG FLAVOR="edge"

# Validate that FLAVOR is either edge/native, cloud isn't supported for forwarder builds
RUN VALIDATE_FLAVOR=$(echo "${FLAVOR}" | tr '[:upper:]' '[:lower:]') && \
    if [ "$VALIDATE_FLAVOR" != "edge" ] && [ "$VALIDATE_FLAVOR" != "native" ]; then \
    echo "Invalid flavor: ${FLAVOR}. Allowed values are: Edge, Native" >&2; \
    exit 1; \
fi

# Install curl, needed for 10x install script
#
RUN apt-get update && apt-get install -y curl

# Install 10x
#
RUN curl https://raw.githubusercontent.com/log-10x/pipeline-releases/main/install.sh | bash -s -- --version ${VERSION} --flavor ${FLAVOR} --no-env-setup


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

# Manually setting up 10x environment variables
#
ENV TENX_HOME=/opt/tenx-edge
ENV TENX_BIN=/opt/tenx-edge/bin/tenx-edge
ENV TENX_MODULES=/opt/tenx-edge/lib/app/modules
ENV TENX_SYMBOLS_PATH=/etc/tenx/symbols
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

# Copy 10x from builder
#
COPY --from=tenx-builder $TENX_SYMBOLS_PATH $TENX_SYMBOLS_PATH
COPY --from=tenx-builder $TENX_CONFIG $TENX_CONFIG
COPY --from=tenx-builder $TENX_HOME $TENX_HOME
