FROM --platform=${BUILDPLATFORM:-linux/amd64} alpine/git:v2.45.2

ARG TARGETPLATFORM
ARG BUILDPLATFORM

COPY ./tenx-config.sh /
RUN chmod +x /tenx-config.sh

ENTRYPOINT ["/tenx-config.sh"]
