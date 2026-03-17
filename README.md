# URL Shortener on AWS ECS Fargate with Self-Managed Kafka

## Overview
This project is a **production-style URL shortener** built with FastAPI and deployed on AWS using ECS Fargate, with a fully automated CI/CD pipeline, hardened networking (no NAT Gateway) and asynchronous analytics engine powered by a self-managed Kafka (Kraft) EC2 Broker.

Highlights:
- OIDC: Github Actions assumes hats using STS
- Kafka: Event-driven architecture
- DynamoDB: Real-time analytics (DynamoDB updates via consumer)
- Hybrid Blue/Green deployment, Canary incremental traffic shift with zero downtime
- Secure, cloud-native infrastructure

---

## Tech Stack
- **Infra:** Terraform 
- **Compute:** AWS ECS Fargate
- **Database:** AWS Dynamodb (Pay-per-request, PITR enabled)
- **Streaming:** Kafka (KRaft mode) acting as Broker on AWS EC2
- **Language:** Python (FastAPI + Uvicorn)
- **CI/CD:** Github Actions + Trivy (Security Scanning)



## Key Features

- URL shortening with hash-based IDs
- DynamoDB for persistent storage
- Kafka event streaming for click tracking
- Real-time analytics via consumer service
- Blue/Green deployments using CodeDeploy shifting traffic Canary style
- Secure AWS setup (IAM roles, no static creds)
- Dockerised microservices for Kafka Consumer and Producer
- Fully automated CI/CD with GitHub Actions

---

## Architecture



### Components

- **Producer API (FastAPI)**
  - Creates short URLs
  - Stores mappings in DynamoDB
  - Publishes click events to Kafka

- **Kafka (Self-managed on EC2)**
  - EC2 acting as Kafka broker
  - EBS volume attahced for peristance 
  - Streams click events

- **Consumer Service**
  - Reads Kafka events
  - Updates click counts in DynamoDB

- **DynamoDB**
  - Stores:
    - `short_url → long_url` for the app (producer)
    - `click_count` → as analytics (consumer)

- **ECS Fargate**
  - Runs both producer + consumer containers severless

- **ALB (Application Load Balancer)**
  - Routes HTTP traffic to FastAPI service

- **AWS CodeDeploy**
  - Handles blue/green deployments

---

## How It Works

1. **Shorten URL**
  **POST/shorten**
- Generates hash-based short ID
- Stores mapping in DynamoDB

2. **GET/short/{id}**
- Uses the method 'GET' to fetch original URL from DynamoDB
- Emits Kafka event ('url-clicks')
- Redirect user

3. **Event Processing**
- Consumer reads Kafka event
- Updates 'click_count' in DynamoDB


1. User sends request to shorten URL:

---

## Testing The Service

1. **Health Check**
- Ensures ALB, WAF and ECS are connected

**Run**
curl -k -i https://<ALB-DNS-NAME>/healthz



