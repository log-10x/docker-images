# 🔟❎ Pipeline

Docker image of a Red Hat (ubi8) container with [Log10x Cloud](http://doc.log10x.com/home/install/#cloud)

## Quick start

Run the latest release with:
``` console
docker run ghcr.io/log-10x/log10x-pipeline:latest
```

## Under the hood

This image is bundled with all the tools that are required by Log10x cloud to work:

- binutils and python38, which are needed for the [compile](http://doc.log10x.com/compile/) pipeline
- [Fluentbit](https://fluentbit.io/), allowing for [cloud analyzer query](http://doc.log10x.com/run/apps/cloud/analyzer/#query) to emit data your destination of chioce.

Visit our [pipeline deployment](http://doc.log10x.com/home/install/docker/#log10x-pipeline) documentation for more info about using this image.

## K8 Deployment

Want to periodically run Log10x in K8? Check out the [Log10x Jobs Helm Chart](https://github.com/log-10x/helm-charts/tree/main/charts/log10x-jobs)
