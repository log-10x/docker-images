"""
AWS Lambda handler for 10x Edge apps on CloudWatch Logs.

Bridges CloudWatch Logs subscription filter events to the 10x Engine
via stdin pipe. Output shipping is handled by the 10x pipeline
configuration (e.g., Fluent Bit output to Datadog, Splunk, Elasticsearch).

Environment variables:
    TENX_API_KEY    - Log10x API key for licensing and metrics
    TENX_APP        - 10x app to run: @apps/edge/reporter, @apps/edge/regulator, or @apps/edge/optimizer
    TENX_EXTRA_ARGS - Optional extra CLI arguments for the 10x engine (space-separated)

Output destination is controlled by the 10x pipeline config, not this handler.
Fluent Bit ships processed events to the configured analytics platform.
See: http://doc.log10x.com/run/output/event/fluentbit/
"""

import base64
import gzip
import json
import os
import subprocess


def handler(event, context):
    """Process CloudWatch Logs subscription filter event through 10x Engine."""

    # --- 1. Decode CloudWatch Logs event ---
    compressed = base64.b64decode(event['awslogs']['data'])
    payload = json.loads(gzip.decompress(compressed))

    log_group = payload.get('logGroup', '')
    log_stream = payload.get('logStream', '')
    log_events = payload.get('logEvents', [])

    if not log_events:
        return {'statusCode': 200, 'body': 'No log events'}

    # Pass CloudWatch metadata as env vars for the 10x pipeline config
    # (e.g., Fluent Bit can include these as tags via TenXEnv.get())
    os.environ['CW_LOG_GROUP'] = log_group
    os.environ['CW_LOG_STREAM'] = log_stream

    # --- 2. Pipe events to 10x Engine via stdin ---
    app = os.environ.get('TENX_APP', '@apps/edge/reporter')
    api_key = os.environ.get('TENX_API_KEY', '')

    cmd = ['tenx', app]
    if api_key:
        cmd += ['-apiKey', api_key]

    extra_args = os.environ.get('TENX_EXTRA_ARGS', '').split()
    if extra_args:
        cmd += extra_args

    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stderr=subprocess.PIPE)

    for e in log_events:
        proc.stdin.write((e['message'] + '\n').encode())
    proc.stdin.close()

    proc.wait(timeout=300)

    if proc.returncode != 0:
        error_msg = proc.stderr.read().decode('utf-8', errors='replace')
        print(f'tenx exited {proc.returncode}: {error_msg}')
        raise RuntimeError(f'tenx failed with exit code {proc.returncode}')

    return {
        'statusCode': 200,
        'body': f'Processed {len(log_events)} events from {log_group}'
    }
