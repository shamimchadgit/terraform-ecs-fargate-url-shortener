# S3 Backend State Locking

terraform {
  backend "s3" {
    bucket = ""
    key = ""
    region = ""
    use_lockfile = true
    encrypt = true
  }
}