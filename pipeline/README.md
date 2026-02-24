# 🔟❎ Pipeline

Docker image of a Red Hat (ubi8) container with [Log10x Cloud](https://doc.log10x.com/architecture/flavors/#cloud)

## Quick start

Run the latest release with:
``` console
docker run ghcr.io/log-10x/log10x-pipeline:latest
```

## Under the hood

This image is bundled with all the tools that are required by Log10x cloud to work:

- binutils and python39, which are needed for the [compile](https://doc.log10x.com/compile/) pipeline
- [Fluentbit](https://fluentbit.io/), allowing for [cloud analyzer query](https://doc.log10x.com/apps/cloud/streamer/#query) to emit data your destination of chioce.

Visit our [pipeline deployment](https://doc.log10x.com/install/docker/) documentation for more info about using this image.

## K8 Deployment

Want to periodically run Log10x in K8? Check out the [Log10x Jobs Helm Chart](https://github.com/log-10x/helm-charts/tree/main/charts/log10x-jobs)
