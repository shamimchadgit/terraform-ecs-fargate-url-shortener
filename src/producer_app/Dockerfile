### Builder Stage 
FROM python:3.12-slim AS builder

WORKDIR /app
# build dependencies (to stop error on slim image)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    libffi-dev \
    libssl-dev \
    python3-dev \
    librdkafka-dev \
    && rm -rf /var/lib/apt/lists/*

# Dependencies 
COPY src/producer_app/requirements.txt .

RUN python3 -m pip install --no-cache-dir --upgrade pip \
    && python3 -m pip install --no-cache-dir -r requirements.txt

### Run-time Stage
FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    librdkafka1 \
    && rm -rf /var/lib/apt/lists/*

#Installed dependencies from builder
COPY --from=builder /usr/local/lib/python3.12 /usr/local/lib/python3.12
COPY --from=builder /usr/local/bin /usr/local/bin

#my app code
COPY src/producer_app/ .
# as have both app.py and ddb.py on CMD can't do "producer_app.app:app" if I don't copy the folder structure instead for both

#Security (run as non-root)
RUN useradd -m appuser
USER appuser

EXPOSE 8080

CMD [ "uvicorn", "app:app", "--host=0.0.0.0", "--port=8080" ]


