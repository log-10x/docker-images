# 10x builder
#
FROM --platform=${BUILDPLATFORM:-linux/amd64} ubuntu:20.04 AS tenx-builder

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


# Filebeat image
FROM --platform=${BUILDPLATFORM:-linux/amd64} docker.elastic.co/beats/filebeat:8.5.1

# Manually setting up 10x environment variables
#
ENV TENX_HOME=/opt/tenx-edge
ENV TENX_BIN=/opt/tenx-edge/bin/tenx-edge
ENV TENX_MODULES=/opt/tenx-edge/lib/app/modules
#
# Setting up the path to config files
# This can be overriden by deployment envs like k8s, when creating user config
#
ENV TENX_CONFIG=/etc/tenx/config
#
# Running 10x with filebeat reporter launch configuration
# This can be overriden by deployment envs like k8s, when creating user config
#
ENV TENX_RUN_ARGS="@run/input/forwarder/filebeat/report/config.yaml @run/apps/edge/reporter"

# Switch to root in order to be able to perform the installation and modification
#
USER root

# Make sure the path for the 'tee' command exists
#
RUN mkdir -p /etc/tenx/debug

# Modify the image entrypoint file, to run filebeat with a pipe into 10x executable
#
RUN sed -i '0,/exec filebeat "$@"/s//exec filebeat "$@" 2\>\&1 | tee \/etc\/tenx\/debug\/raw_filebeat.log | $TENX_BIN run $TENX_RUN_ARGS/' /usr/local/bin/docker-entrypoint

# Copy 10x from builder
#
COPY --from=tenx-builder $TENX_CONFIG $TENX_CONFIG
COPY --from=tenx-builder $TENX_HOME $TENX_HOME

# Switch back tothe filebeat user, same as original image
#
USER filebeat
