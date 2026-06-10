# Copyright (c) 2025-2026 Log10x, Inc.
# SPDX-License-Identifier: Apache-2.0

# The compiler image is a LITERAL EXTENSION of pipeline-10x: identical engine,
# config, modules, symbols, baked license and tooling (incl. fluent-bit) — plus
# the source-fetch toolchain (git, docker CLI, helm) the compile 'pull' stage
# shells out to. It is built AFTER pipeline-10x (see `needs: Pipeline` in
# publish_10x_all_containers.yaml) and pulls that exact tag as its base.

ARG ENGINE_VERSION
ARG ENGINE_IMAGE=log10x/pipeline-10x:${ENGINE_VERSION}

FROM ${ENGINE_IMAGE}

# Override the inherited pipeline OCI labels
LABEL org.opencontainers.image.title="Log10x Compiler"
LABEL org.opencontainers.image.description="Log10x AOT symbol compiler: pipeline-10x plus the source-fetch toolchain (git, docker CLI, helm)"
LABEL org.opencontainers.image.source="https://github.com/log-10x/docker-images"

ARG TARGETPLATFORM
# Pinned versions of the bundled source-fetch CLIs (bump as needed).
ARG DOCKER_CLI_VERSION=27.3.1
ARG HELM_VERSION=v3.16.4

USER root

# Source-fetch toolchain for the compile 'pull' stage:
#   git        - pull source from git repos
#   docker CLI - docker-image pull/scan (client only; needs a mounted
#                /var/run/docker.sock or a remote DOCKER_HOST at runtime)
#   helm       - pull/render Helm charts
# Drop the inherited fluent-bit repo file first so this install doesn't try to
# refresh it over the network (fluent-bit itself stays installed from the base).
RUN rm -f /etc/yum.repos.d/fluent-bit.repo && \
    microdnf install -y git tar gzip && \
    case "${TARGETPLATFORM:-linux/amd64}" in \
      "linux/arm64") DOCKER_ARCH=aarch64 ; HELM_ARCH=arm64 ;; \
      *)             DOCKER_ARCH=x86_64  ; HELM_ARCH=amd64 ;; \
    esac && \
    curl -fsSL "https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-${DOCKER_CLI_VERSION}.tgz" \
      | tar -xz -C /tmp docker/docker && \
    install -m 0755 /tmp/docker/docker /usr/local/bin/docker && \
    curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-${HELM_ARCH}.tar.gz" \
      | tar -xz -C /tmp && \
    install -m 0755 /tmp/linux-${HELM_ARCH}/helm /usr/local/bin/helm && \
    rm -rf /tmp/docker /tmp/linux-${HELM_ARCH} && \
    microdnf clean all

USER tenxuser

# Default to running the compiler. ENTRYPOINT, all TENX_* env, the baked
# license and the tenxuser/workdir are inherited from pipeline-10x.
CMD [ "@apps/compiler" ]
