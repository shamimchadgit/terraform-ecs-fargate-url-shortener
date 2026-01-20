# Provider Block

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.14.1"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
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