# 10x Lambda — CloudWatch Logs Optimization

Deploy the 10x Engine as an AWS Lambda container image that processes CloudWatch Logs before shipping to analytics platforms. A drop-in replacement for log forwarder Lambdas (e.g., [Datadog Forwarder](https://docs.datadoghq.com/logs/guide/forwarder/)).

## How It Works

1. CloudWatch delivers batched log events via subscription filter
2. Python handler decodes the payload and pipes log lines to the 10x Engine's stdin
3. 10x Engine processes the stream (report, regulate, or optimize)
4. Fluent Bit ships processed events to the configured destination (Datadog, Splunk, Elasticsearch, etc.)

## Quick Start

```bash
# Build
docker build -t 10x-lambda .

# Push to ECR
aws ecr create-repository --repository-name 10x-lambda
aws ecr get-login-password | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com
docker tag 10x-lambda <account>.dkr.ecr.<region>.amazonaws.com/10x-lambda:latest
docker push <account>.dkr.ecr.<region>.amazonaws.com/10x-lambda:latest

# Create Lambda
aws lambda create-function \
    --function-name 10x-lambda \
    --package-type Image \
    --code ImageUri=<account>.dkr.ecr.<region>.amazonaws.com/10x-lambda:latest \
    --role arn:aws:iam::<account>:role/<lambda-execution-role> \
    --memory-size 512 \
    --timeout 300 \
    --environment "Variables={TENX_API_KEY=<key>,DD_API_KEY=<key>,TENX_APP=@apps/edge/optimizer}"

# Subscribe to a CloudWatch Log Group
aws logs put-subscription-filter \
    --log-group-name <your-log-group> \
    --filter-name 10x-optimizer \
    --filter-pattern "" \
    --destination-arn arn:aws:lambda:<region>:<account>:function:10x-lambda
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `TENX_API_KEY` | Yes | Log10x API key |
| `TENX_APP` | No | `@apps/edge/reporter`, `@apps/edge/regulator`, or `@apps/edge/optimizer` (default: reporter) |
| `TENX_EXTRA_ARGS` | No | Additional CLI arguments for the 10x engine |

Output destination is controlled by the 10x pipeline config via Fluent Bit output plugins. Set env vars for your destination:

| Destination | Variables |
|-------------|-----------|
| Datadog | `DD_API_KEY`, `DD_SITE` |
| Splunk | `SPLUNK_HOST`, `SPLUNK_PORT`, `SPLUNK_HEC_TOKEN` |
| Elasticsearch | `ELASTICSEARCH_HOST`, `ELASTICSEARCH_PORT`, `ELASTICSEARCH_USERNAME`, `ELASTICSEARCH_PASSWORD` |
| CloudWatch | AWS credentials via IAM role or env vars |

## Documentation

Full deployment guide: [doc.log10x.com/architecture/launcher/lambda](http://doc.log10x.com/architecture/launcher/lambda/)
