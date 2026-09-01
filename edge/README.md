# 🔟❎ Edge

Docker image of a lightweight Debian (bookworm-slim) container with the [Log10x runtime](https://doc.log10x.com/engine/flavors/) as a GraalVM native binary.

## Quick start

Run the latest release with:
``` console
docker run ghcr.io/log-10x/edge-10x:latest
```

No license is needed to evaluate: the engine runs on its built-in 30-day evaluation license (10 nodes, airgapped). For a production license, see [licensing](https://doc.log10x.com/manage/license/) and pass it as `-e TENX_LICENSE_KEY="$(cat license.jwt)"`. See [log10x.com/pricing](https://www.log10x.com/pricing?utm_source=github&utm_medium=readme&utm_campaign=docker-images&utm_content=inline).

## Under the hood

This image contains the Log10x Edge native binary — a GraalVM ahead-of-time compiled executable with no JVM dependency. It is designed for:

- **Sidecar deployments** alongside log forwarders ([Fluentd](https://www.fluentd.org/), [Fluent Bit](https://fluentbit.io/), [OTel Collector](https://opentelemetry.io/docs/collector/))
- **Real-time log/trace optimization** at the edge using the [Forward protocol](https://doc.log10x.com/run/input/forward/)
- **Minimal resource footprint** — small image size, fast startup, low memory usage

Visit our [sidecar deployment](https://doc.log10x.com/engine/launcher/sidecar/) and [Docker deployment](https://doc.log10x.com/install/docker/) documentation for more info about using this image.

## K8s Deployment

Want to deploy Log10x Edge as a sidecar in K8s? Check out the [Log10x Helm Charts](https://github.com/log-10x/helm-charts)
