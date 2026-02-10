from fastapi import FastAPI, HTTPException
from fastapi.responses import RedirectResponse, HTMLResponse
from pydantic import BaseModel
import hashlib
import time
from ddb import put_mapping, get_mapping

app = FastAPI(title="URL Shortener")

class ShortenRequest(BaseModel):
    URL: str

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
                or <code>GET /&lt;id&gt;</code> to resolve it.
            </p>
        </body>
    </html>
    """

# Health check endpoint (ECS/ALB)
@app.get("/healthz")
def health():
    return {"status": "OK", "ts": int(time.time())}

# short url endpoint
@app.post("/shorten")
def shorten(payload: ShortenRequest):
    url = payload.URL
    
    # short HASH ID
    short = hashlib.sha256(url.encode("utf-8")).hexdigest()[:8]
    
    try:
        put_mapping(short_id, url)
    except Exception as e:
        print("DynamoDB error:", e)
        raise HTTPException(status_code=500, detail="Failed to store URL")
    return {
        "short": short_id,
        "URL": url
    }
    
# Resolve short url
@app.get("/short/{short_id}")
def resolve(short_id: str):
    item = get_mapping(short_id)
    
    if not item:
        raise HTTPException(status_code=404, detail="Not Found")
    full_url = item.get("full_url")
    if not full_url:
        raise HTTPException(status_code=500, detail="Corrupt data")
    return RedirectResponse(full_url)
    
