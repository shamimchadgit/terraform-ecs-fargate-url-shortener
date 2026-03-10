output "s3_arn" {
  value = aws_s3_bucket.tf_state.arn
}

output "kms_arn" {
  value = aws_kms_key.tf_state.arn
}

output "bucket_name" {
  value = aws_s3_bucket.tf_state.id
}