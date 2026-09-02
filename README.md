# 🔟❎ Docker Images

This repository holds and publishes the docker files for the public releases of [Log10x](https://www.log10x.com/?utm_source=github&utm_medium=readme&utm_campaign=docker-images&utm_content=hero).

Log10x is an **Observability runtime**, it is to log/trace data what Chrome V8 is to JavaScript:
an engine for dynamically optimizing execution with the goal improving performance and reducing the cost of data processing.

## Edge

Docker image of a lightweight Debian (bookworm-slim) container with the [Log10x runtime](https://doc.log10x.com/engine/flavors/) as a GraalVM native binary.

Designed for [sidecar deployments](https://doc.log10x.com/engine/launcher/sidecar/) alongside log forwarders (Fluentd, Fluent Bit, OTel Collector), providing real-time log/trace optimization at the edge with minimal resource footprint.

Visit our [Docker deployment](https://doc.log10x.com/install/docker/) documentation for more info about using this image.

## Pipeline

Docker image of a Red Hat (ubi8) container with the [Log10x compiler](https://doc.log10x.com/engine/flavors/)

Visit our [Docker deployment](https://doc.log10x.com/install/docker/) documentation for more info about using this image.

## Quarkus

Docker image of a [Quarkus](https://quarkus.io/) server capable of invoking [Log10x pipelines](https://doc.log10x.com/engine/pipeline/) on demand with the [Log10x compiler](https://doc.log10x.com/engine/flavors/) capabilities.

Visit our [Docker deployment](https://doc.log10x.com/install/docker/) documentation for more info about using this image.

## License

This repository is licensed under the [MIT License](LICENSE).

### Log10x Product License

This repository contains Dockerfiles and build tooling for Log10x containers.
While the build files are open source, **the Log10x binaries installed in
these images require a license to use.**

| What's Open Source | What Requires License |
|-------------------|----------------------|
| Dockerfiles in this repo | Log10x binaries installed in images |
| Build scripts | Running Log10x containers |
| Container configuration | Log10x engine features |

Images carry no license. Started without one, the engine runs the built-in
evaluation license: the full product, 30 days from process start, 10 nodes,
air-gapped, with no outbound call. Pass your own token to license a
deployment:

```console
-e TENX_LICENSE_KEY="$(cat license.jwt)"
```

**Get a Log10x License:**
- [Pricing](https://www.log10x.com/pricing?utm_source=github&utm_medium=readme&utm_campaign=docker-images&utm_content=footer)
- [Documentation](https://doc.log10x.com)
- [Contact Sales](mailto:sales@log10x.com)
