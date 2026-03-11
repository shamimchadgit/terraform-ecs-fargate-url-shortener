### Builder Stage 
FROM python:3.12-slim AS builder

WORKDIR /app
# Dependencies 
RUN apt-get update && apt-get install -y gcc librdkafka-dev

COPY src/analytics_consumer/requirements.txt .

RUN python3 -m pip install --no-cache-dir --upgrade pip \
    && python3 -m pip install --no-cache-dir -r requirements.txt

### Run-time Stage
FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && apt-get install -y librdkafka1

#Installed dependencies from builder
COPY --from=builder /usr/local/lib/python3.12 /usr/local/lib/python3.12
COPY --from=builder /usr/local/bin /usr/local/bin

#my app code
COPY src/analytics_consumer/consumer.py .

#Security (run as non-root)
RUN useradd -m appuser
USER appuser

CMD ["python", "consumer.py"]

