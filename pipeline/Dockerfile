FROM registry.access.redhat.com/ubi8/ubi:8.10

# Install binutils (strings), needed for l1x 'compile'
#
RUN dnf install -y binutils

# Install python3, needed for l1x 'compile'
#
RUN dnf install -y python38

# Install fluent-bit, used for forwarding data from L1x pipeline
# to any supported destination, needed for certain 'run' configurations
#
COPY ./fluent-bit.repo /etc/yum.repos.d/fluent-bit.repo
RUN dnf install -y fluent-bit

# Install L1x
#
COPY ./l1x.rpm /tmp/l1x.rpm
RUN dnf install -y /tmp/l1x.rpm && rm /tmp/l1x.rpm

# Clean up the dnf cache to reduce image size
#
RUN dnf clean all

# Make sure path for log file exists, so L1X_LOG_APPENDER can be changed to l1xFileAppender if desired
RUN mkdir -p /var/log/l1x && chown 185 /var/log/l1x

# Set L1X_BIN env var
#
ENV L1X_BIN=/opt/l1x-cloud/bin/l1x-cloud

# Set l1x logger to console.
#
ENV L1X_LOG_APPENDER=l1xConsoleAppender

ENTRYPOINT [ "/opt/l1x-cloud/bin/l1x-cloud" ]

CMD [ "run" ]
