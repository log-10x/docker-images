# 🔟❎ Pipeline

Docker image of a Red Hat (ubi8) container with the [Log10x compiler](https://doc.log10x.com/engine/flavors/)

## Quick start

Run the latest release with:
``` console
docker run ghcr.io/log-10x/log10x-pipeline:latest
```

The image ships with a built-in limited license. For the full engine, download your own from [console.log10x.com](https://console.log10x.com) and pass it as `-e TENX_LICENSE_KEY="$(cat license.jwt)"`. See [log10x.com/pricing](https://www.log10x.com/pricing?utm_source=github&utm_medium=readme&utm_campaign=docker-images&utm_content=inline).

## Under the hood

This image is bundled with all the tools that are required by the Log10x compiler to work:

- binutils and python39, which are needed for the [compile](https://doc.log10x.com/compile/) pipeline
- [Fluentbit](https://fluentbit.io/), allowing pipeline output to be emitted to your destination of choice.

Visit our [pipeline deployment](https://doc.log10x.com/install/docker/) documentation for more info about using this image.

## K8 Deployment

Want to periodically run Log10x in K8? Check out the [Log10x Jobs Helm Chart](https://github.com/log-10x/helm-charts/tree/main/charts/log10x-jobs)
