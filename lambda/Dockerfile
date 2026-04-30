# Lambda runtime image for the log10x Retriever Lambda flavor.
#
# Java/Quarkus engine packaged for AWS Lambda — runs the indexer/query/
# subquery/stream pipeline as Lambda functions backed by the same engine
# code that powers the K8s/Quarkus retriever flavor. Consumed by the
# log-10x/terraform-aws-tenx-retriever-lambda module.
#
# Built by .github/workflows/publish_10x_lambda.yaml in this repo. That
# workflow downloads the tenx-lambda-<version>.tar.gz release artifact
# from the engine release (produced by engine's lambda_build.yaml),
# extracts it into the build context, then `docker buildx build` against
# this Dockerfile. So the build context is expected to contain:
#   ./run-lambda-<version>-all.jar
#   ./log4j2.yaml
#   ./LICENSE
#
# Image format constraints:
# - --provenance=false --sbom=false on buildx, otherwise Lambda rejects
#   the OCI manifest at CreateFunction time.
# - The Dockerfile itself is arch-agnostic (both base images —
#   `log10x/quarkus-10x` and `public.ecr.aws/lambda/java:21` — are
#   multi-arch). publish_10x_lambda.yaml builds linux/amd64 and
#   linux/arm64 separately and joins them into a multi-arch manifest at
#   the version-only tag, so consumers can pull the variant matching
#   their function's `architectures` setting.

ARG ENGINE_VERSION
ARG ENGINE_IMAGE=log10x/quarkus-10x:${ENGINE_VERSION}

# Stage 1: pull tenx-home (config / modules / symbols) from the matching
# quarkus image so the Lambda image always tracks the engine release —
# no separate tenx-home staging step.
FROM ${ENGINE_IMAGE} AS engine

# Stage 2: AWS Lambda Java runtime base (multi-arch; we pin platform on
# the build invocation, not here).
FROM public.ecr.aws/lambda/java:21

COPY --from=engine /etc/tenx/config  ${LAMBDA_TASK_ROOT}/tenx-home/config/
COPY --from=engine /etc/tenx/modules ${LAMBDA_TASK_ROOT}/tenx-home/modules/
COPY --from=engine /etc/tenx/symbols ${LAMBDA_TASK_ROOT}/tenx-home/config/data/shared/symbols/

# Lambda-flavored log4j2 config — sends everything to SYSTEM_OUT
# (CloudWatch). Replaces the stock quarkus image config which wires
# rolling-file + Fluentd targets that fail on Lambda's read-only fs.
COPY log4j2.yaml ${LAMBDA_TASK_ROOT}/tenx-home/config/log4j2.yaml

# Shadow jar — single fat jar with the Lambda Runtime Interface Client +
# all engine + extension classes.
COPY run-lambda-*-all.jar ${LAMBDA_TASK_ROOT}/lib/

ENV TENX_HOME=/var/task/tenx-home \
    TENX_CONFIG=/var/task/tenx-home/config \
    TENX_MODULES=/var/task/tenx-home/modules \
    TENX_SYMBOLS_PATH=/var/task/tenx-home/config/data/shared/symbols \
    TENX_LOG_APPENDER=tenxConsoleAppender \
    TENX_LOG_PATH=/tmp/

CMD [ "com.log10x.ext.lambda.RetrieverHandler::handleRequest" ]
