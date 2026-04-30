# lambda-10x — Retriever Lambda runtime image

Java/Quarkus engine packaged for AWS Lambda. Runs the indexer / query / subquery / stream pipelines as Lambda functions backed by the same engine code that powers the K8s/Quarkus retriever flavor. Consumed by the [`log-10x/terraform-aws-tenx-retriever-lambda`](https://github.com/log-10x/terraform-aws-tenx-retriever-lambda) module.

## Image source + publishing

This image is **not** built locally — it's built and published by [`.github/workflows/publish_10x_lambda.yaml`](../.github/workflows/publish_10x_lambda.yaml). The workflow:

1. Downloads `tenx-lambda-<version>.tar.gz` from the matching engine release (produced by `engine/.github/workflows/lambda_build.yaml`). The tarball contains the run-lambda shadow jar + Lambda-flavored `log4j2.yaml` + LICENSE.
2. Extracts the tarball into the Docker build context alongside this `Dockerfile`.
3. `docker buildx build --provenance=false --sbom=false` per arch (linux/amd64 + linux/arm64).
4. Pushes to `docker.io/log10x/lambda-10x:<version>` and `ghcr.io/log-10x/lambda-10x:<version>` as a multi-arch manifest joining both arches. Consumers pull the variant matching their Lambda function's `architectures` setting.

## Image format constraints

- **`--provenance=false --sbom=false`** on the buildx invocation, otherwise Lambda rejects the OCI manifest at `CreateFunction` time.
- Single-arch tags (`<version>-amd64`, `<version>-aarch64`) are also pushed and remain pullable directly if you ever need to pin a specific arch.

## What the image contains

Multi-stage build:

- **Stage 1 (`engine`)**: pulls `log10x/quarkus-10x:<version>` for tenx-home (config, modules, symbols). The Lambda image always tracks the matching engine release — no separate tenx-home staging.
- **Stage 2 (`public.ecr.aws/lambda/java:21`)**: AWS Lambda Java runtime base. Receives the tenx-home tree, the Lambda-flavored `log4j2.yaml`, and the run-lambda shadow jar.

Entry point: `com.log10x.ext.lambda.RetrieverHandler::handleRequest`.

## Manual build (only for debugging the Dockerfile)

The workflow handles publishing — manual builds are only useful for iterating on the Dockerfile itself.

```bash
# Get the tarball (download from a recent engine release)
gh release download <version> --pattern "tenx-lambda-*.tar.gz" -R log-10x/<release-repo>
tar -xzvf tenx-lambda-*.tar.gz

# Build the image
docker buildx build \
  --platform linux/amd64 \
  --provenance=false --sbom=false \
  --build-arg ENGINE_VERSION=<version> \
  -t lambda-10x:<version> \
  .
```

## Where the image runs

Demo cluster: pulled from `docker.io/log10x/lambda-10x:<tag>` by the demo terraform's mirror null_resource ([backend/terraform/demo/retriever-lambda.tf](https://github.com/log-10x/backend/blob/main/terraform/demo/retriever-lambda.tf)), retagged into the demo account's private ECR (Lambda only loads images from same-account private ECR), then referenced by `aws_lambda_function` resources in the `terraform-aws-tenx-retriever-lambda` module.
