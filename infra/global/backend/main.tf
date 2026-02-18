# S3 Bucket (terraform state)

resource "aws_s3_bucket" "tf_state" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = var.prevent_destroy
  }
}

# Enable s3 versioning 

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = var.status
  } 
}

# KMS Key

resource "aws_kms_key" "tf_state" {
  description = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}


# Enable encryption

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tf_state.arn
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = var.bucket_key_enabled
  }
}

# Block public acces to s3 bucket

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls = true
  block_public_policy = true  
  ignore_public_acls = true
  restrict_public_buckets = true
}

# Bucket ownership controls

resource "aws_s3_bucket_ownership_controls" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


# IAM policy for terraform

resource "aws_iam_policy" "s3_policy" {
  name = "s3-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [ "s3:ListBucket" ]
        Resource = "${aws_s3_bucket.tf_state.arn}"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "${aws_kms_key.tf_state.arn}"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.tf_state.arn}/*"
      }
    ]
  })
}

# S3 state policy

resource "aws_iam_role_policy_attachment" "tf_state" {
  role =
  policy_arn = aws_iam_policy.s3_policy.arn
}

