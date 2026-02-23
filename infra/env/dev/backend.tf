# S3 Backend State Locking
terraform {
  required_version = ">= 1.6.0"
}

terraform {
  backend "s3" {
    bucket = "tf-state-url-short-26"
    key = "dev/terraform.tfstate"
    region = "eu-west-2"
    use_lockfile = true
    encrypt = true
  }
} 