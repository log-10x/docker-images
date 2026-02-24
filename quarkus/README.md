# 🔟❎ Quarkus

Docker image of a [Quarkus](https://quarkus.io/) server capable of invoking [Log10x pipelines](https://doc.log10x.com/architecture/pipeline/) on demand with [Log10x Cloud](https://doc.log10x.com/architecture/flavors/#cloud) capabilities.

## Quick start

Run the latest release with:
``` console
docker run ghcr.io/log-10x/log10x-quarkus:latest
```

## Under the hood

This image is built on [Quarkus](https://quarkus.io/), the Supersonic Subatomic Java Framework.

Additionally, this image is bundled with all the tools that are required by Log10x cloud to work:

- binutils and python39, which are needed for the [compile](https://doc.log10x.com/compile/) pipeline
- [Fluentbit](https://fluentbit.io/), allowing for [cloud analyzer query](https://doc.log10x.com/apps/cloud/streamer/#query) to emit data your destination of chioce.

Visit our [quarkus deployment](https://doc.log10x.com/install/docker/) documentation for more info about using this image.

## K8 Deployment

Want to deploy a cluster of Log10x quarkus servers to K8? Check out the [Log10x Quarkus Helm Chart](https://github.com/log-10x/helm-charts/tree/main/charts/log10x-quarkus)
