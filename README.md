# 🔟❎ Docker Images

This repository holds and publishes the docker files for the public releases of [Log10x](http://doc.log10x.com).

Log10x is an **Observability runtime**, it is to log/trace data what Chrome V8 is to JavaScript:
an engine for dynamically optimizing execution with the goal improving performance and reducing the cost of data processing.

## Pipeline

Docker image of a Red Hat (ubi8) container with [Log10x Cloud](http://doc.log10x.com/home/install/#cloud)

Visit our [pipeline deployment](http://doc.log10x.com/home/install/docker/#log10x-pipeline) documentation for more info about using this image.

## Quarkus

Docker image of a [Quarkus](https://quarkus.io/) server capable of invoking [Log10x pipelines](http://doc.log10x.com/home/pipeline/) on demand with [Log10x Cloud](http://doc.log10x.com/home/install/#cloud) capabilities.

Visit our [quarkus deployment](http://doc.log10x.com/home/install/docker/#log10x-quarkus-server) documentation for more info about using this image.

## License

This repository is licensed under the [Apache License 2.0](LICENSE).

### Important: Log10x Product License Required

This repository contains Dockerfiles and build tooling for Log10x containers.
While the build files are open source, **the Log10x binaries installed in
these images require a commercial license to use.**

| What's Open Source | What Requires License |
|-------------------|----------------------|
| Dockerfiles in this repo | Log10x binaries installed in images |
| Build scripts | Running Log10x containers |
| Container configuration | Log10x engine features |

**Get a Log10x License:**
- [Pricing](https://log10x.com/pricing)
- [Documentation](https://doc.log10x.com)
- [Contact Sales](mailto:sales@log10x.com)
