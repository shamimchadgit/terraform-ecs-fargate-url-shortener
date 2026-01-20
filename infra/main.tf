# DynamoDB Table 

module "dynamodb" {
  source = "./modules/dynamodb"
  dynamodb_table_name = "url-shortener"
}

# ALB

module "alb" {
  source    = "./modules/alb"
  vpc_id    = module.network.vpc_id
  subnets   = module.network.public_subnet_ids
  alb_sg_id = module.network.alb_sg_id
  certificate_arn = module.acm.certifcate_arn
}

# Network 

module "network" {
  source = "./modules/network"

}

# WAF

module "waf" {
  source  = "./modules/waf"
  alb_arn = module.alb.alb_arn
}


# ECS

module "ecs" {
  source             = "./modules/ecs"
  dynamodb_table_arn = module.dynamodb.table_arn
  table_name = module.dynamodb.table_name
  target_group_arn   = module.alb.tg_blue_arn
  subnets = module.network.private_subnet_ids
  service_sg_ids = module.network.ecs_sg_id
}

# Route53

module "route_53" {
  source = "./modules/route53"
  domain_name = var.domain_name
  domain_validation_options = module.acm.domain_validation_options
  alb_dns_name = module.alb.dns_name
  alb_zone_id = module.alb.zone_id
}

# ACM

module "acm" {
  source = "./modules/acm"
  domain_name = module.route_53.route53_hosted_zone
  validation_record_fqdns = module.route_53.acm_validation_fqdns
}