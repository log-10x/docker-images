# Copyright (c) 2025-2026 Log10x, Inc.
# SPDX-License-Identifier: Apache-2.0

# The compiler image is a LITERAL EXTENSION of pipeline-10x: identical engine,
# config, modules, symbols, baked license and tooling (incl. fluent-bit) — plus
# the source-fetch toolchain (git, podman, helm) the compile 'pull' stage
# shells out to. It is built AFTER pipeline-10x (see `needs: Pipeline` in
# publish_10x_all_containers.yaml) and pulls that exact tag as its base.

ARG ENGINE_VERSION
ARG ENGINE_IMAGE=log10x/pipeline-10x:${ENGINE_VERSION}

FROM ${ENGINE_IMAGE}

# Override the inherited pipeline OCI labels
LABEL org.opencontainers.image.title="Log10x Compiler"
LABEL org.opencontainers.image.description="Log10x AOT symbol compiler: pipeline-10x plus the source-fetch toolchain (git, podman, helm)"
LABEL org.opencontainers.image.source="https://github.com/log-10x/docker-images"

ARG TARGETPLATFORM
# Pinned version of the bundled helm CLI (bump as needed).
ARG HELM_VERSION=v3.16.4

USER root

# Source-fetch toolchain for the compile 'pull' stage:
#   git     - pull source from git repos
#   podman  - docker-image pull/scan, DAEMONLESS. The engine materializes an
#             image's filesystem by shelling out to `docker create` + `docker
#             export`; podman runs those verbs with no daemon and no host socket.
#             Symlinked as /usr/local/bin/docker so the engine's default
#             `command` uses it unchanged. Runtime image pull needs CAP_SYS_ADMIN
#             plus STORAGE_DRIVER=vfs (set below); no /var/run/docker.sock mount.
#   helm    - pull/render Helm charts
# Drop the inherited fluent-bit repo file first so this install doesn't try to
# refresh it over the network (fluent-bit itself stays installed from the base).
RUN rm -f /etc/yum.repos.d/fluent-bit.repo && \
    microdnf install -y git tar gzip podman && \
    ln -sf /usr/bin/podman /usr/local/bin/docker && \
    case "${TARGETPLATFORM:-linux/amd64}" in \
      "linux/arm64") HELM_ARCH=arm64 ;; \
      *)             HELM_ARCH=amd64 ;; \
    esac && \
    curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-${HELM_ARCH}.tar.gz" \
      | tar -xz -C /tmp && \
    install -m 0755 /tmp/linux-${HELM_ARCH}/helm /usr/local/bin/helm && \
    rm -rf /tmp/linux-${HELM_ARCH} && \
    microdnf clean all

# Daemonless podman uses vfs storage (overlay would need /dev/fuse plus a device
# plugin in k8s); vfs works with just CAP_SYS_ADMIN at runtime.
ENV STORAGE_DRIVER=vfs

USER tenxuser

# Default to running the compiler. ENTRYPOINT, all TENX_* env, the baked
# license and the tenxuser/workdir are inherited from pipeline-10x.
CMD [ "@apps/compiler" ]
