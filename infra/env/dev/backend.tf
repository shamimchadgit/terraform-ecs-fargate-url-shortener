# S3 Backend State Locking
terraform {
  required_version = ">= 1.6.0"
}

terraform {
  backend "s3" {
    bucket       = "tf-state-url-short-kafka-26"
    key          = "global/terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
    encrypt      = true
  }
} 