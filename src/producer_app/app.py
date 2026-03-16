from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import RedirectResponse, HTMLResponse
from pydantic import BaseModel
import hashlib
import time
import atexit
from ddb import put_mapping, get_mapping
from confluent_kafka import Producer
import os
import json

# Kafka Producer Config

KAFKA_BOOTSTRAP = os.getenv("KAFKA_BOOTSTRAP")
if not KAFKA_BOOTSTRAP:
    raise RuntimeError("KAFKA_BOOTSTRAP not set")

producer = Producer({
    "bootstrap.servers": KAFKA_BOOTSTRAP
})

def delivery_report(err, msg):
    """Kafka delivery callback."""
    if err:
        print(f"❌ Delivery failed for record {msg.key()}: {err}")
    else:
        print(f"✅ Message delivered to {msg.topic()} [{msg.partition()}]")

# Shutdown flush (gracefully)
atexit.register(lambda: producer.flush())

# FastAPI app

app = FastAPI(title="URL Shortener")

class ShortenRequest(BaseModel):
    url: str

# HTML landing page
@app.get("/", response_class=HTMLResponse)
def root():
    return """
    <html>
        <head>
            <title>URL Shortener</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    text-align: center;
                    margin-top: 50px;
                }
                input, button {
                    padding: 10px;
                    margin: 5px;
                    width: 300px;
                }
                h1 { color: #333; }
            </style>
        </head>
        <body>
            <h1>Welcome to the URL Shortener</h1>
            <p>
                Use <code>POST /shorten</code> to shorten a URL via JSON,
                or <code>GET /short/&lt;id&gt;</code> to resolve it.
            </p>
        </body>
    </html>
    """

# Health check endpoint (ECS/ALB)
@app.get("/healthz")
def health():
    return {"status": "OK", "ts": int(time.time())}

# Short url endpoint
@app.post("/shorten")
def shorten(payload: ShortenRequest):
    url = payload.url
    
    # short HASH ID (timestamp salt reduce collision risk)
    short_url = hashlib.sha256(
        f"{url}{time.time()}".encode("utf-8")).hexdigest()[:8]
    
    try:
        put_mapping(short_url, url)
    except Exception as e:
        print("DynamoDB error:", e)
        raise HTTPException(status_code=500, detail="Failed to store URL")
    return {
        "short": short_url,
        "URL": url
    }
    
# Resolve short url
@app.get("/short/{short_url}")
def resolve(short_url: str):
    item = get_mapping(short_url)
    
    if not item:
        raise HTTPException(status_code=404, detail="Not Found")
    full_url = item.get("long_url")
    if not full_url:
        raise HTTPException(status_code=500, detail="Corrupt data")
    
# Emit Kafka event    
    try: 
        event = {
            "short_code": short_url,
            "timestamp": int(time.time())
        }
        producer.produce(
            topic="url-clicks",
            value=json.dumps(event),
            callback=delivery_report
        )
        producer.poll(0) # trigger delivery callback
   
    except Exception as e:
        print("🚨 Kafka error:", e)
        
    return RedirectResponse(full_url)
 
### Test FastAPI works 
# from fastapi import FastAPI

# app = FastAPI()

# @app.get("/")
# def read_root():
#     return {"message": "Hello World"}
