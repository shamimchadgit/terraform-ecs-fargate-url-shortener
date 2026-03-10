aws_region               = "eu-west-2"
bucket_name              = "tf-state-url-short-kafka-26"
domain_name              = "dev.shamimchaudhury.uk"
cluster_name             = "url-shortener"
service_name             = "url-shortener-cluster-svc"
repo_name                = "url_shortener_app"
dynamodb_table_name      = "url-shortener"
cidr                     = "10.0.0.0/16"
public_subnets_cidr      = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets_cidr     = ["10.0.101.0/24", "10.0.102.0/24"]
app_image_repo_name      = "url_shortener_app"
consumer_image_repo_name = "analytics-consumer"
ssl_policy               = "ELBSecurityPolicy-TLS-1-2-2017-01"
policy_name              = "ecs-task-ddb-policy"
github_repo              = ""
certificate_arn          = ""

