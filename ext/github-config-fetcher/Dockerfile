# Copyright (c) 2025-2026 Log10x, Inc.
# SPDX-License-Identifier: Apache-2.0

FROM --platform=${BUILDPLATFORM:-linux/amd64} alpine:3.21

RUN apk add --no-cache git

# OCI Image Labels - Community Tool (no Log10x license required)
LABEL org.opencontainers.image.title="Log10x Config Fetcher"
LABEL org.opencontainers.image.description="Utility for fetching Log10x configurations from GitHub"
LABEL org.opencontainers.image.vendor="Log10x, Inc."
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.documentation="https://doc.log10x.com"
LABEL org.opencontainers.image.source="https://github.com/log-10x/docker-images"

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION=unknown

RUN addgroup -S fetcher && adduser -S -G fetcher -h /data fetcher && \
    mkdir -p /data && chown fetcher:fetcher /data

COPY ./tenx-config.sh /
RUN sed -i 's/\r$//' /tenx-config.sh && \
    sed -i "s/__VERSION__/${VERSION}/g" /tenx-config.sh && \
    chmod +x /tenx-config.sh

USER fetcher

ENTRYPOINT ["/tenx-config.sh"]
