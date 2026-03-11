aws_region              = "eu-west-2"
bucket_name             = "tf-state-url-short-kafka-26"
domain_name             = "dev.shamimchaudhury.uk"
cluster_name            = "url-shortener"
service_name            = "url-shortener-cluster-svc"
repo_name               = "url_shortener_app"
consumer_repo_name      = "analytics-consumer"
dynamodb_table_name     = "url-shortener"
cidr                    = "10.0.0.0/16"
public_subnets_cidr     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets_cidr    = ["10.0.101.0/24", "10.0.102.0/24"]
github_repo             = "shamimchadgit/terraform-ecs-fargate-url-shortener-kafka"
ssl_policy              = "ELBSecurityPolicy-TLS-1-2-2017-01"
blue_target_group_name  = "url-shortener-tg-blue"
green_target_group_name = "url-shortener-tg-green"
policy_arn              = "arn:aws:s3:::url-shortener-kafka-assets-dev"
s3_arn                  = "arn:aws:s3:::tf-state-url-short-kafka-26"
kms_arn                 = "arn:aws:kms:eu-west-2:317006682416:key/ac300053-5b53-49fd-a318-2f4e8687a445"





