# 10x Lambda — CloudWatch Logs optimization for Datadog
#
# Extends the standard 10x pipeline image with the AWS Lambda Runtime
# Interface Client, enabling deployment as an AWS Lambda container image.
#
# Build:
#   docker build -t 10x-lambda .
#
# Push to ECR:
#   aws ecr get-login-password | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com
#   docker tag 10x-lambda <account>.dkr.ecr.<region>.amazonaws.com/10x-lambda:latest
#   docker push <account>.dkr.ecr.<region>.amazonaws.com/10x-lambda:latest

FROM ghcr.io/log-10x/pipeline-10x:latest

# awslambdaric: AWS Lambda Runtime Interface Client for container images
RUN pip3 install --no-cache-dir awslambdaric

COPY handler.py /app/handler.py

WORKDIR /app

ENTRYPOINT ["python3", "-m", "awslambdaric"]
CMD ["handler.handler"]
