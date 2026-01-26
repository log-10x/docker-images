import sys
import time
import argparse
import boto3
from botocore.exceptions import ClientError
from botocore import UNSIGNED
from botocore.config import Config

def stream_local_file(file_path):
    try:
        with open(file_path, 'r') as file:
            while True:
                for line in file:
                    line = line.strip()
                    if line:
                        yield line
                file.seek(0)
    except FileNotFoundError:
        print(f"Error: File {file_path} not found")
        sys.exit(1)

def stream_s3_file(bucket, key, anonymous=False):
    try:
        if anonymous:
            s3 = boto3.client('s3', config=Config(signature_version=UNSIGNED))
        else:
            s3 = boto3.client('s3')
        
        response = s3.get_object(Bucket=bucket, Key=key)
        for line in response['Body'].iter_lines():
            line = line.decode('utf-8').strip()
            if line:
                yield line
        # Restart by re-fetching the object
        while True:
            response = s3.get_object(Bucket=bucket, Key=key)
            for line in response['Body'].iter_lines():
                line = line.decode('utf-8').strip()
                if line:
                    yield line
    except ClientError as e:
        print(f"Error accessing S3: {e}")
        sys.exit(1)

def log_simulator(source_type, file_path=None, bucket=None, key=None, lines_per_second=1, anonymous_s3=False):
    try:
        rate = float(lines_per_second)
        if rate <= 0:
            raise ValueError("Lines per second must be positive")

        if source_type == "local":
            if not file_path:
                raise ValueError("File path must be provided for local source")
            line_generator = stream_local_file(file_path)
        elif source_type == "s3":
            if not bucket or not key:
                raise ValueError("Bucket and key must be provided for S3 source")
            line_generator = stream_s3_file(bucket, key, anonymous_s3)
        else:
            raise ValueError("Source type must be 'local' or 's3'")

        for line in line_generator:
            print(line)
            sys.stdout.flush()
            time.sleep(1.0 / rate)

    except ValueError as e:
        print(f"Error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Log simulator emitting lines to stdout.")
    parser.add_argument("--source", choices=["local", "s3"], default="local", help="Source type: local file or S3")
    parser.add_argument("--file", help="Path to local log file")
    parser.add_argument("--bucket", help="S3 bucket name")
    parser.add_argument("--key", help="S3 object key")
    parser.add_argument("--rate", type=float, default=1, help="Lines per second")
    parser.add_argument("--anonymous-s3", action="store_true", help="Access public S3 bucket without credentials")

    args = parser.parse_args()

    log_simulator(args.source, args.file, args.bucket, args.key, args.rate, args.anonymous_s3)
