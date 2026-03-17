# URL Shortener on AWS ECS Fargate with Self-Managed Kafka

## Overview
This project is a **production-style URL shortener** built with FastAPI and deployed on AWS using ECS Fargate, with a fully automated CI/CD pipeline, hardened networking (no NAT Gateway) and asynchronous analytics engine powered by a self-managed Kafka (Kraft) broker running on EC2.

the system is designed to demonstarte modern-cloud-native architecture principles including event-driven design, secure infrastructure and zero-downtime deployments.

## Why This Project

Historic URL shorteners are often tightly coupled systems when analytics processing happens synchronously. This provides a single point of failure, in-turn increases latency and limits scalability. 

This project illustrates how to build secure, cost-conscious AWS infrastructure that:
- Decouples user-facing operations from analytics processing
- Enables real-time data streaming without impacting performance
- Leave room for scalability

Highlights:
- **OIDC:** Omits long-lived credentials using GitHub Actions OIDC (least-privilege principle)
- **Kafka:** Event-driven architecture decouples services and enbales asynchronous processing
- **DynamoDB:** Real-time analytic streams (DynamoDB updates via consumer)
- **Hybrid Deployment:** Blue/Green, Canary incremental traffic shift with zero downtime
- **Secure Networking:** Private subnets, VPC endpoints and no NAT Gateway
- **Cloud-Native Design:** Fully containerised microservices on ECS Fargate

---

## Architecture Diagram

![image alt](https://github.com/shamimchadgit/terraform-ecs-fargate-url-shortener-kafka/blob/0c2c298f765c615123548c2bdb25ec2bc6fc4d8f/architecture.drawio.png)

---

## Tech Stack
- **Infra:** Terraform 
- **Compute:** AWS ECS Fargate
- **Database:** AWS Dynamodb (on-demand, PITR enabled)
- **Streaming:** Kafka Broker as AWS EC2, ECS services acting as Producer and Consumer 
- **Persistence:** EBS mounted to EC2, emmulates Kafka's retention over other message brokers
- **Backend:** Python (FastAPI + Uvicorn)
- **Frontend:** HTML (UI)
- **CI/CD:** Github Actions + Trivy (security scanning)

---

## Key Features

- URL shortening with hash-based IDs
- Persistent storage using DynamoDB
- Kafka-based event streaming for click tracking
- Real-time analytics via consumer service
- Blue/Green deployments with Canary traffic shifting
- Secure AWS setup (IAM roles, no static credentials)
- Multi-stage Dockerised builds for Kafka Consumer and Producer containers
- Fully automated CI/CD pipeline with GitHub Actions

---

## How It Works

1. **Shorten URL**
`POST/shorten`
- Generates hash-based short ID
- Stores mapping in DynamoDB
- Returns shortened URL

2. **Resolve URL**
`GET/short/{id}`
- Uses the method 'GET' to fetch original URL from DynamoDB
- Emits Kafka event ('url-clicks')
- Redirect user

3. **Event Processing**
- Consumer reads topic
- Updates 'click_count' in DynamoDB

---

## Putting it to the Test (API Examples)

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

### Components

- **Producer App (FastAPI)**
  - Connects app to Kafka Broker (EC2)
  - Creates short URLs 
  - Stores mappings in DynamoDB
  - Resolves short URLs
  - Publishes click events
  - Exposes health check endpoints

- **Consumer App**
- Subscribes to topic 'url-clicks'
- Updates click counts in DynamoDB

- **Kafka (Self-managed on EC2)**
  - Single-node Kafka broker (KRaft mode)
  - EBS volume attached for persistence 
  - Streams click events between services

- **DynamoDB**
  - Stores:
    - `short_url → long_url` for the app (producer)
    - `click_count` → as analytics (consumer)

- **ECS Fargate**
  - Runs both producer + consumer containers severlessly

- **ALB (Application Load Balancer)**
  - Routes HTTP traffic to FastAPI service
  - Performs health checks

- **AWS CodeDeploy**
  - Handles blue/green deployments with Canary shift

- **Security:**
  - OIDC authentication for CI/CD (no long-lived credentials)
  - IAM roles with least-privilege access
  - Private subnets for ECS services
  - VPC endpoints for AWS services (no NAT Gateway)
  - Security groups isolating Kafka broker and services
 
- **Observability:**
  - CloudWatch logs for ECS services
  - ALB metrics for traffic and health checks
  - Kafka logs stored on EC2 instance
  - Deployment visibility via CodeDeploy 

---

## Trade-offs
- **Kafka on EC2 vs MSK:**
To remain cost-conscious, I deployed Kafka on a single EC2 instance with IAM Role to pull Kraft       tarball pulled from S3 assets bucket. This provides the power of a message Broker without the         high hourly cost of Managed Streaming for Kafka (MSK).

- **VPC Endpoints vs NAT Gateway:** Avoiding NAT GW could've made my bootstrap script for my EC2   Broker simplier by using 'wget' to fetch apache Kafka, which in-turn would save provisioning another s3 to store the tar file. 
Nevertheless, refactoring S3 endpoint was a good use of DRY and minimising architectural bill that is inherted by NAT Gateway.

- **Static EC2 vs ASG:** If at any point I wanted to accomodate for high-availability it would be cost-optimised to use scaling policies - only pay for what I need. 
However, as my set-up does not feature a mulit-node Kafka cluster, to use a static EC2 makes more sense to avoid complex code like provisioning other moving parts e.g. launch templates. 

---

## Limitations
- Single-node Kafka (no replication or fault tolerance)
- No rate limiting or abuse protection
- No custom URL aliases
- Limited observability (no distributed tracing)
- No caching layer for frequently accessed URLs

---

## Future Improvements
- Migrate to multi-node Kafka cluster or managed streaming service
- Introduce Redis for caching and performance improvements
- Add API Gateway + WAF for rate limiting and security
- Implement distributed tracing (e.g. OpenTelemetry)
- Build a frontend dashboard for analytics visualisation
- Improve autoscaling strategies for ECS services

---

## Demonstrations
The screenshots below illustrate the deployment and workflows working in unison: 

**CodeDeploy Deployment**

![image alt](https://github.com/shamimchadgit/terraform-ecs-fargate-url-shortener-kafka/blob/9d109eff17758faaebc03287f745e42a3f0ad193/codedeploy.png)



**Deploy Producer App**

![image alt](https://github.com/shamimchadgit/terraform-ecs-fargate-url-shortener-kafka/blob/cd1fd13aaa154d3071a7d1ff414cd21327513095/deploy-app.png)


**Deploy Consumer App**

![image alt](https://github.com/shamimchadgit/terraform-ecs-fargate-url-shortener-kafka/blob/e7a2226b7dbf951af583118d3724893b3994ce89/deploy-consumer.png)

**Terraform Plan**
- Triggered by a PR if a team is working and changes are being made

![image alt](https://github.com/shamimchadgit/terraform-ecs-fargate-url-shortener-kafka/blob/56098081fb79f9a5f30914bdc15511d3b880b136/terraform-plan.png)

**Terraform Apply**

![image alt](https://github.com/shamimchadgit/terraform-ecs-fargate-url-shortener-kafka/blob/3028e4723d610a10fbcb5f8afd6b329b42740135/terraform-apply.png)

**Terraform Destroy**








