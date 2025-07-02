FROM --platform=${BUILDPLATFORM:-linux/amd64} public.ecr.aws/lambda/java:21

ARG TARGETPLATFORM
ARG BUILDPLATFORM

# Installing the lambda insights extension, for in depth monitoring
#
RUN case "$TARGETPLATFORM" in \
    "linux/arm64") \
      curl -O https://lambda-insights-extension-arm64.s3-ap-northeast-1.amazonaws.com/amazon_linux/lambda-insights-extension-arm64.rpm && \
      rpm -U lambda-insights-extension-arm64.rpm && \
      rm -f lambda-insights-extension-arm64.rpm ;; \
    "linux/amd64") \
      curl -O https://lambda-insights-extension.s3-ap-northeast-1.amazonaws.com/amazon_linux/lambda-insights-extension.rpm && \
      rpm -U lambda-insights-extension.rpm && \
      rm -f lambda-insights-extension.rpm ;; \
    *) \
      echo "Unsupported TARGETPLATFORM: $TARGETPLATFORM" && exit 1 ;; \
    esac

# Install binutils (strings), needed for 10x 'compile'
#
RUN dnf install -y binutils

# Install python3, needed for 10x 'compile'
#
RUN dnf install -y python3

# Install fluent-bit, used for forwarding data from 10x pipeline
# to any supported destination, needed for certain 'run' configurations
#
COPY ./fluent-bit.repo /etc/yum.repos.d/fluent-bit.repo
RUN dnf install -y fluent-bit

# Clean up the dnf cache to reduce image size
#
RUN dnf clean all

# License key should be overriden by deployment (k8 helm) or config file
#
ENV TENX_LICENSE=NO-LICENSE

# Set 10x logger to console.
#
ENV TENX_LOG_APPENDER=tenxConsoleAppender

# Copy the 10x modules and config
#
COPY ./modules ${LAMBDA_TASK_ROOT}/lib/modules
COPY ./config ${LAMBDA_TASK_ROOT}/lib/config

# Set env paths to modules and config
#
ENV TENX_MODULES=${LAMBDA_TASK_ROOT}/lib/modules
ENV TENX_CONFIG=${LAMBDA_TASK_ROOT}/lib/config

# Copy 10x jar
#
COPY ./lib/run-lambda-*-all.jar ${LAMBDA_TASK_ROOT}/lib/lambda-10x.jar

# Set the CMD to the RunLambda handler
CMD [ "com.log10x.ext.lambda.run.RunLambda::handleRequest" ]
