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
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir --upgrade pip

# Dependencies 
COPY requirements.txt .

RUN python3 -m pip install --no-cache-dir -r requirements.txt

### Run-time Stage
FROM python:3.12-slim

WORKDIR /app

#Installed dependencies from builder
COPY --from=builder /root/.local /home/appuser/.local

#my app code
COPY . .
# as have both app.py and ddb.py on CMD can't do "producer_app.app:app" if I don't copy the folder structure instead for both

#Security (run as non-root)
RUN useradd -m appuser
USER appuser

ENV PATH=/home/appuser/.local/bin:$PATH

EXPOSE 8080

CMD [ "uvicorn", "app:app", "--host=0.0.0.0", "--port=8080" ]


