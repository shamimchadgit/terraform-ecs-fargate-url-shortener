# Provider Block

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

default_tags {
  tags = {
    Project = "url-shortener"
  }
}

  #Localstack
  #access_key = "test"
  #secret_key = "test"
  #skip_credentials_validation = true
  #skip_metadata_api_check = true
  #skip_requesting_account_id = true

  #endpoints {
  #dynamodb = "http://localhost:4566"
  #ecs = "http://localhost:4566"
  #}
}