FROM registry.access.redhat.com/ubi8/ubi:8.10

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

# Install Log10x
#
COPY ./log10x.rpm /tmp/log10x.rpm
RUN dnf install -y /tmp/log10x.rpm && rm /tmp/log10x.rpm

# Clean up the dnf cache to reduce image size
#
RUN dnf clean all

# Make sure path for log file exists, so L1X_LOG_APPENDER can be changed to l1xFileAppender if desired
RUN mkdir -p /var/log/l1x && chown 185 /var/log/l1x

# Set L1X_BIN env var
#
ENV L1X_BIN=/opt/log10x-cloud/bin/log10x-cloud

# Set Log10x logger to console.
#
ENV L1X_LOG_APPENDER=l1xConsoleAppender

ENTRYPOINT [ "/opt/log10x-cloud/bin/log10x-cloud" ]

CMD [ "run" ]
