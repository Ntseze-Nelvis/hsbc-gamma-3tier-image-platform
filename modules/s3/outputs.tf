output "raw_bucket_arn" {
  value = aws_s3_bucket.raw.arn
}

output "processed_bucket_arn" {
  value = aws_s3_bucket.processed.arn
}

output "kms_key_arn" {
  value = aws_kms_key.s3_kms.arn
}
