# 🔟❎ Quarkus

Docker image of a [Quarkus](https://quarkus.io/) server capable of invoking [Log10x pipelines](http://doc.log10x.com/home/pipeline/) on demand with [Log10x Cloud](http://doc.log10x.com/home/install/#cloud) capabilities.

## Quick start

Run the latest release with:
``` console
docker run ghcr.io/log-10x/log10x-quarkus:latest
```

## Under the hood

This image is built on [Quarkus](https://quarkus.io/), the Supersonic Subatomic Java Framework.

Additionally, this image is bundled with all the tools that are required by Log10x cloud to work:

- binutils and python38, which are needed for the [compile](http://doc.log10x.com/compile/) pipeline
- [Fluentbit](https://fluentbit.io/), allowing for [cloud analyzer query](http://doc.log10x.com/run/apps/cloud/analyzer/#query) to emit data your destination of chioce.

Visit our [quarkus deployment](http://doc.log10x.com/home/install/docker/#log10x-quarkus-server) documentation for more info about using this image.

## K8 Deployment

Want to deploy a cluster of Log10x quarkus servers to K8? Check out the [Log10x Quarkus Helm Chart](https://github.com/log-10x/helm-charts/tree/main/charts/log10x-quarkus)
