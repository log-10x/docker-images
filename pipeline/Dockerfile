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

FROM --platform=${BUILDPLATFORM:-linux/amd64} registry.access.redhat.com/ubi8/ubi:8.10

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG FLAVOR="cloud"

# Install binutils (strings), needed for 10x 'compile'
#
RUN dnf install -y binutils

# Install python3, needed for 10x 'compile'
#
RUN dnf install -y python38

# Install fluent-bit, used for forwarding data from 10x pipeline
# to any supported destination, needed for certain 'run' configurations
#
COPY ./fluent-bit.repo /etc/yum.repos.d/fluent-bit.repo
RUN dnf install -y fluent-bit

# Clean up the dnf cache to reduce image size
#
RUN dnf clean all

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

# License key should be overriden by deployment (k8 helm) or config file
#
ENV TENX_LICENSE=NO-LICENSE

# Set 10x logger to console.
#
ENV TENX_LOG_APPENDER=tenxConsoleAppender

# Copy 10x from builder
#
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
