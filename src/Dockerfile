### Builder Stage 
FROM python:3.12-slim AS builder

WORKDIR /app
# Dependencies 
COPY requirements.txt .

RUN python3 -m pip install --no-cache-dir --upgrade pip \ 
    && python3 -m pip install --no-cache-dir -r requirements.txt

### Run-time Stage
FROM python:3.12-slim

WORKDIR /app

#Installed dependencies from builder
COPY --from=builder /usr/local/lib/python3.12 /usr/local/lib/python3.12
COPY --from=builder /usr/local/bin /usr/local/bin

#my app code
COPY app.py .
COPY ddb.py .

#Security (run as non-root)
RUN useradd -m appuser
USER appuser

EXPOSE 8080

CMD [ "uvicorn", "app:app", "--host=0.0.0.0", "--port=8080" ]


#FROM python:3.12-slim
#WORKDIR /app
# Creates hidden directory called /app

#RUN pip install --no-cache-dir fastapi uvicorn boto3
# using python package manager (pip) to install webframework (fastapi), the server to run the framework (uvicorn) and AWS SDK for python (boto3)
# no-cache-dir (don't store temp files to keep img small)

#COPY . .
#COPY tests ./tests
# COPY <source> <destination> 
# src/ actual computer path where dockerfile is
# . = look at the current folder that docker lives (src) and ./app.py = ./ = app ∴ = app/app.py/.
# So container pathway = /app/src/tests/app.py

#EXPOSE 8080
#CMD [ "uvicorn", "app:app", "--host=0.0.0.0", "--port=8080" ]

#uvicorn runs fastAPI app
# app:app - app (/app/app.py) inside the container app directory we set and second app is FastAPI instance inside that app.py (e.g. app = FastAPI())
# host -> make server accessible from outside the container
# app listens on port 8080 

