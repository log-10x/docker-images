# Copyright (c) 2025-2026 Log10x, Inc.
# SPDX-License-Identifier: Apache-2.0

FROM --platform=${BUILDPLATFORM:-linux/amd64} python:3.12-slim

# OCI Image Labels - Community Tool (no Log10x license required)
LABEL org.opencontainers.image.title="Log10x Log Simulator"
LABEL org.opencontainers.image.description="Utility for generating sample log data for testing"
LABEL org.opencontainers.image.vendor="Log10x, Inc."
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.documentation="https://doc.log10x.com"
LABEL org.opencontainers.image.source="https://github.com/log-10x/docker-images"

WORKDIR /app

RUN pip install boto3

COPY log-simulator.py .
COPY sample.txt .

ENTRYPOINT ["python", "log-simulator.py"]
CMD ["--source", "local", "--file", "sample.txt", "--rate", "10"]
