# Log10x builder
#
FROM --platform=${BUILDPLATFORM:-linux/amd64} ubuntu:20.04 AS log10x-builder

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


# Filebeat image
FROM --platform=${BUILDPLATFORM:-linux/amd64} docker.elastic.co/beats/filebeat:8.5.1

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
#
# Running log10x with filebeat reporter launch configuration
# This can be overriden by deployment envs like k8s, when creating user config
#
ENV L1X_COMMAND="@input/forwarder/filebeat/report/config.yaml"

# Switch to root in order to be able to perform the installation and modification
#
USER root

# Modify the image entrypoint file, to run filebeat with a pipe into l1x executable
#
RUN sed -i '0,/exec filebeat "$@"/s//exec filebeat "$@" 2\>\&1 | $L1X_BIN configFolder $L1X_CONFIG_PATH $L1X_COMMAND/' /usr/local/bin/docker-entrypoint

# Copy log10x from builder
#
COPY --from=log10x-builder $L1X_CONFIG_PATH $L1X_CONFIG_PATH
COPY --from=log10x-builder $L1X_HOME $L1X_HOME

# Switch back tothe filebeat user, same as original image
#
USER filebeat
