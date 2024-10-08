FROM --platform=${BUILDPLATFORM:-linux/amd64} registry.access.redhat.com/ubi8/ubi:8.10 AS log10x-builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
ARG FLAVOR="cloud"

# Install curl, needed for Log10x install script
#
RUN dnf install -y curl

# Install Log10x
#
RUN curl https://raw.githubusercontent.com/log-10x/pipeline-releases/main/install.sh | bash -s -- --version ${VERSION} --flavor ${FLAVOR} --no-env-setup

FROM --platform=${BUILDPLATFORM:-linux/amd64} registry.access.redhat.com/ubi8/ubi:8.10

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG FLAVOR="cloud"

# Install binutils (strings), needed for Log10x 'compile'
#
RUN dnf install -y binutils

# Install python3, needed for Log10x 'compile'
#
RUN dnf install -y python38

# Install fluent-bit, used for forwarding data from Log10x pipeline
# to any supported destination, needed for certain 'run' configurations
#
COPY ./fluent-bit.repo /etc/yum.repos.d/fluent-bit.repo
RUN dnf install -y fluent-bit

# Clean up the dnf cache to reduce image size
#
RUN dnf clean all

# Make sure path for log file exists, so L1X_LOG_APPENDER can be changed to l1xFileAppender if desired
#
RUN mkdir -p /var/log/l1x && chown 185 /var/log/l1x

# Manually setting up Log10x environment variables
#
ENV L1X_HOME=/opt/log10x-${FLAVOR}
ENV L1X_BIN=/opt/log10x-${FLAVOR}/bin/log10x-${FLAVOR}
ENV L1X_CONFIG_PATH=/etc/log10x/config

# Set Log10x logger to console.
#
ENV L1X_LOG_APPENDER=l1xConsoleAppender

# Copy log10x from builder
#
COPY --from=log10x-builder $L1X_CONFIG_PATH $L1X_CONFIG_PATH
COPY --from=log10x-builder $L1X_HOME $L1X_HOME

ENTRYPOINT [ "sh", "-c", "exec $L1X_BIN \"${@}\"", "--" ]

CMD [ "run" ]
