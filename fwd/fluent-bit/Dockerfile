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


# Fluent-bit image
#
FROM --platform=${BUILDPLATFORM:-linux/amd64} fluent/fluent-bit:3.1.7

# Manually setting up Log10x environment variables
#
ENV L1X_HOME=/opt/log10x-edge
ENV L1X_BIN=/opt/log10x-edge/bin/log10x-edge
ENV L1X_MODULES_PATH=/opt/log10x-edge/lib/app/modules
#
# Setting up the path to config files
# This can be overriden by deployment envs like k8s, when creating user config
#
ENV L1X_CONFIG_PATH=/etc/log10x/config

# Copying a minimal shell from the builder
#
# This is needed because l1x.lua invokes the l1x pipeline runable by
# calling io.popen, which relies on a /bin/sh -c call to work
#
# For more info, see:
# https://man7.org/linux/man-pages/man3/popen.3.html
# https://www.lua.org/manual/5.4/manual.html#pdf-io.popen
#
COPY --from=log10x-builder /bin/dash /bin/sh

# Copy log10x from builder
#
COPY --from=log10x-builder $L1X_CONFIG_PATH $L1X_CONFIG_PATH
COPY --from=log10x-builder $L1X_HOME $L1X_HOME
