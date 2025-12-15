FROM --platform=${BUILDPLATFORM:-linux/amd64} alpine/git:v2.45.2

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION=unknown

COPY ./tenx-config.sh /
RUN sed -i "s/__VERSION__/${VERSION}/g" /tenx-config.sh && \
    chmod +x /tenx-config.sh

ENTRYPOINT ["/tenx-config.sh"]
