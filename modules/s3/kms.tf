# KMS Key for S3 Buckets
resource "aws_kms_key" "s3_kms" {
  description             = "KMS key for S3 image buckets"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "s3_kms_alias" {
  name          = "alias/${var.project_name}-s3"
  target_key_id = aws_kms_key.s3_kms.key_id
}

# raw images bucket
resource "aws_s3_bucket" "raw" {
  bucket = var.raw_bucket_name

  tags = {
    Name = "${var.project_name}-raw-images"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "raw" {
  bucket = aws_s3_bucket.raw.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_kms.arn
    }
  }
}


# # s3 access policy for app role
# data "aws_iam_policy_document" "app_s3_policy" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "s3:GetObject",
#       "s3:PutObject",
#       "s3:ListBucket"
#     ]

#     resources = [
#       "arn:aws:s3:::${var.raw_bucket_name}",
#       "arn:aws:s3:::${var.raw_bucket_name}/*",
#       "arn:aws:s3:::${var.processed_bucket_name}",
#       "arn:aws:s3:::${var.processed_bucket_name}/*"
#     ]
#   }

#   # More specific KMS permissions using the key ARN from the s3 module
#   statement {
#     effect = "Allow"

#     actions = [
#       "kms:GenerateDataKey",
#       "kms:Decrypt",
#       "kms:Encrypt"
#     ]

#     resources = [
#       module.s3.kms_key_arn  # This will need to be passed as a variable
#     ]
#   }
# }









