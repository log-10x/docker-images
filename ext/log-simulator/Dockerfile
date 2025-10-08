FROM --platform=${BUILDPLATFORM:-linux/amd64} python:3.12-slim

WORKDIR /app

RUN pip install boto3

COPY log-simulator.py .
COPY sample.txt .

ENTRYPOINT ["python", "log-simulator.py"]
CMD ["--source", "local", "--file", "sample.txt", "--rate", "10"]
