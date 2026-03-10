# Network 

module "network" {
  source = "../../modules/network"

}

# ECR

module "ecr" {
  source             = "../../modules/ecr"
  latest_img         = 5
  untagged_count_num = 10

}

# DynamoDB Table 

module "dynamodb" {
  source              = "../../modules/dynamodb"
  dynamodb_table_name = "url-shortener"
}

# ACM

module "acm" {
  source                  = "../../modules/acm"
  domain_name             = var.domain_name
  validation_record_fqdns = module.route_53.acm_validation_fqdns
}

# ALB

module "alb" {
  source          = "../../modules/alb"
  vpc_id          = module.network.vpc_id
  subnets         = module.network.public_subnet_ids
  alb_sg_id       = module.network.alb_sg_id
  certificate_arn = module.acm.certificate_arn
}

# ECS

module "ecs" {
  source             = "../../modules/ecs"
  dynamodb_table_arn = module.dynamodb.table_arn
  table_name         = module.dynamodb.table_name
  target_group_arn   = module.alb.tg_blue_arn
  subnets            = module.network.private_subnet_ids
  service_sg_ids     = [module.network.ecs_sg_id]
  image = module.ecr.ecr_image_url
  kafka_bootstrap = "${module.kafka.kafka_private_ip}:9092"
}

# Code Deploy

module "codedeploy" {
  source                  = "../../modules/ecs-codedeploy"
  cluster_name            = module.ecs.ecs_cluster_name
  service_name            = module.ecs.ecs_service_name
  blue_target_group_name  = module.alb.tg_blue_name
  green_target_group_name = module.alb.tg_green_name
  alb_listener_arn        = module.alb.alb_listener
  alb_test_listener_arn   = module.alb.alb_test_listener
}

# WAF

module "waf" {
  source  = "../../modules/waf"
  alb_arn = module.alb.alb_arn
}

# Route53

module "route_53" {
  source                    = "../../modules/route53"
  domain_name               = var.domain_name
  domain_validation_options = module.acm.domain_validation_options
  alb_dns_name              = module.alb.dns_name
  alb_zone_id               = module.alb.zone_id
}

# IAM Github Actions OIDC

module "iam_github_oidc" {
  source                      = "../../modules/iam-github-oidc"
  ecr_repo_arn                = module.ecr.ecr_repo_arn
  ecs_task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.ecs.ecs_task_role_arn
  s3_arn = module.backend.s3_arn
  kms_arn = module.backend.kms_arn
  ecr_consumer_repo_arn = module.ecr.ecr_consumer_repo_arn
}

# Kafka

module "kafka" {
  source = "../../modules/kafka"
  private_sub_id = module.network.private_subnet_ids[0]
  kafka_assets_s3_bucket = aws_s3_bucket.kafka_assets.arn

  depends_on = [ aws_s3_object.kafka_binary ]
}

# ECS - Consumer

module "ecs_consumer" {
  source = "../../modules/ecs-consumer"
  execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecr_image_url = module.ecr.consumer_image_url
  ecs_cluster_id = module.ecs.ecs_cluster_id
  kafka_bootstrap = "${module.kafka.kafka_private_ip}:9092"
  table_name = module.dynamodb.table_name
  subnet_ids = module.network.private_subnet_ids
  consumer_sg_ids = [module.network.ecs_consumer_sg_id]
  dynamodb_table_arn = module.dynamodb.table_arn
  cluster_name = "${module.ecs.ecs_cluster_name}-ecs-analytics-consumer"

}

resource "aws_s3_bucket" "kafka_assets" {
  bucket = "url-shortener-kafka-assets-dev"
}

resource "aws_s3_object" "kafka_binary" {
  bucket = aws_s3_bucket.kafka_assets.id
  key = "kafka_2.13-4.2.0.tgz"
  source = "${path.module}/../../../assets/kafka_2.13-4.2.0.tgz"

  etag = filemd5("${path.module}/../../../assets/kafka_2.13-4.2.0.tgz")
}


