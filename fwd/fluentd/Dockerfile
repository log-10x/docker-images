# Log10x builder
#
FROM --platform=${BUILDPLATFORM:-linux/amd64} debian:bookworm-slim AS log10x-builder

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

# Install curl, needed for Log10x install script
#
RUN apt-get update && apt-get install -y curl

# Install Log10x
#
RUN curl https://raw.githubusercontent.com/log-10x/pipeline-releases/main/install.sh | bash -s -- --version ${VERSION} --flavor ${FLAVOR} --no-env-setup


# Fluentd image
#
FROM --platform=${BUILDPLATFORM:-linux/amd64} fluent/fluentd-kubernetes-daemonset:v1.17-debian-elasticsearch8-1

ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Manually setting up Log10x environment variables
#
ENV L1X_HOME=/opt/log10x-edge
ENV L1X_BIN=/opt/log10x-edge/bin/log10x-edge
ENV L1X_MODULES=/opt/log10x-edge/lib/app/modules
#
# Setting up the path to config files
# This can be overriden by deployment envs like k8s, when creating user config
#
ENV L1X_CONFIG=/etc/log10x/config

# Copy log10x from builder
#
COPY --from=log10x-builder $L1X_CONFIG $L1X_CONFIG
COPY --from=log10x-builder $L1X_HOME $L1X_HOME
