# URL Shortener on AWS ECS Fargate with Self-Managed Kafka

## Overview
This project is a **production-style URL shortener** built with FastAPI and deployed on AWS using ECS Fargate, with a fully automated CI/CD pipeline, hardened networking (no NAT Gateway) and asynchronous analytics engine powered by a self-managed Kafka (Kraft) EC2 Broker.

Highlights:
- **OIDC:** Omits use of long-lived access keys highlighting least-privellege principle
- **Kafka:** Event-driven architecture avoids tight coupling and synchronous execution
- **DynamoDB:** Real-time analytic streams (DynamoDB updates via consumer)
- **Hybrid Deployment:** Blue/Green deployment, Canary incremental traffic shift with zero downtime
- Secure, cloud-native infrastructure

---

## Architecture Diagram

---

## Tech Stack
- **Infra:** Terraform 
- **Compute:** AWS ECS Fargate
- **Database:** AWS Dynamodb (Pay-per-request, PITR enabled)
- **Streaming:** Kafka Broker as AWS EC2, ECS services acting as Producer and Consumer 
- **Persistence:** EBS mounted to EC2, emmulates Kafka's retention over other message brokers
- **Language:** Python (FastAPI + Uvicorn), HTML(UI)
- **CI/CD:** Github Actions + Trivy (Security Scanning)

---

## Key Features

- URL shortening with hash-based IDs
- DynamoDB for persistent storage
- Kafka event streaming for click tracking
- Real-time analytics via consumer service
- Blue/Green deployments using CodeDeploy shifting traffic Canary style
- Secure AWS setup (IAM roles, no static creds)
- Multi-stage Dockerised microservices for Kafka Consumer and Producer
- Fully automated CI/CD with GitHub Actions

---

### Components

- **Producer App (FastAPI)**
  - Connects app to Kafka Broker (EC2)
  - Creates short URLs
  - Health check endpoint used by ALB/ECS 
  - Stores mappings in DynamoDB
  - Resolves short URL endpoint
  - Publishes click events to Kafka

- **Consumer App**
- Subscribes to topic 'url-clicks'
- Updates click counts in DynamoDB


- **Kafka (Self-managed on EC2)**
  - EC2 acting as Kafka broker
  - EBS volume attached for persistance 
  - Streams click events

- **DynamoDB**
  - Stores:
    - `short_url → long_url` for the app (producer)
    - `click_count` → as analytics (consumer)

- **ECS Fargate**
  - Runs both producer + consumer containers severless

- **ALB (Application Load Balancer)**
  - Routes HTTP traffic to FastAPI service

- **AWS CodeDeploy**
  - Handles blue/green deployments with Canary shift

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

---

## Putting it to the Test

1. **Health Check**
- Ensures ALB, WAF and ECS are connected

**Run**
`curl -k -i https://<ALB-DNS-NAME>/healthz`

![image alt](https://github.com/shamimchadgit/terraform-ecs-fargate-url-shortener-kafka/blob/672dc954191586f3efd41ffc2e8628aaee6b8aa3/Testing_Service.png)


2. **Shorten URL (Producer)**
- Triggers a write to DynamoDB via VPC Gateway Endpoint

**Run**
curl -k -X POST https://<ALB-DNS-NAME>/shorten \
     -H "Content-Type: application/json" \
     -d '{"url": "https://dev.shamimchaudhury.uk"}

![image alt](https://github.com/shamimchadgit/terraform-ecs-fargate-url-shortener-kafka/blob/20d8b699c0e0c2c2f81fa38c0526e3c8fe0d72a5/Shorten_url.png)



3. **Resolve and Analytics**
- Triggers a read from DynamoDB and emits an event to the EC2 Kafka Broker

**Run**
`curl -k -i https://<ALB-DNS-NAME>/short/<ID>`

![image alt](https://github.com/shamimchadgit/terraform-ecs-fargate-url-shortener-kafka/blob/1d541ea06805b67bb55fd7de549aae8b63864950/Resolve_Analytics.png)

---

## Trade-offs
- **Kafka on EC2 vs MSK:** To remain cost-conscious, I deployed Kafka on a single EC2 instance with IAM Role to pull Kraft tarball pulled from S3 assets bucket. This provides the power of a message Broker without the high hourly cost of Managed Streaming for Kafka (MSK).
- **VPC Endpoints vs NAT Gateway:** Avoiding NAT GW could've made my bootstrap script for my EC2 Broker simplier by using 'wget' to fetch apache Kafka, which in-turn would save provisioning another s3 to store the tar file. 
Nevertheless, refactoring S3 endpoint was a good use of DRY and minimising architectural bill that is inherted by NAT Gateway. 
- **Static EC2 vs ASG:** If at any point I wanted to accomodate for high-availability it would be cost-optimised to use scaling policies - only pay for what I need. 
However, as my set-up does not feature a mulit-node Kafka cluster, to use a static EC2 makes more sense to avoid complex code like provisioning other moving parts e.g. launch templates. 

---

## Demonstrations
The screenshots below illustrate the deployment and workflows working in unison: 

**CodeDeploy Deployment**

![image alt]()



**Deploy Producer App**


**Deploy Consumer App**

**Terraform Plan**
- Triggered by a PR if a team is working and changes are being made

**Terraform Apply**

**Terraform Destroy**








