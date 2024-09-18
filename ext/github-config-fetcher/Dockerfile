FROM --platform=${BUILDPLATFORM:-linux/amd64} alpine/git:v2.45.2

ARG TARGETPLATFORM
ARG BUILDPLATFORM

COPY ./log10x-config.sh /
RUN chmod +x /log10x-config.sh

ENTRYPOINT ["/log10x-config.sh"]
