# create lifecycle rule for raw bucket
resource "aws_s3_bucket_lifecycle_configuration" "raw" {
  bucket = aws_s3_bucket.raw.id

  rule {
    id     = "raw-images-expiry"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}

# create lifecycle rule for processed bucket
resource "aws_s3_bucket_lifecycle_configuration" "processed" {
  bucket = aws_s3_bucket.processed.id

  rule {
    id     = "processed-images-transition"
    status = "Enabled"

    transition {
      days          = 60
      storage_class = "STANDARD_IA"
    }
  }
}

# bucket policy (app tier needs access to both buckets)
data "aws_iam_policy_document" "raw_bucket_policy" {

  # Bucket-level permissions
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.app_role_arn]
    }

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.raw.arn
    ]
  }

  # Object-level permissions
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.app_role_arn]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.raw.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "raw_policy" {
  bucket = aws_s3_bucket.raw.id
  policy = data.aws_iam_policy_document.raw_bucket_policy.json
}

# bucket policy for processed bucket
data "aws_iam_policy_document" "processed_bucket_policy" {

  # Bucket-level permissions
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.app_role_arn]
    }

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.processed.arn
    ]
  }

  # Object-level permissions
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.app_role_arn]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.processed.arn}/*"
    ]
  }
}


resource "aws_s3_bucket_policy" "processed_policy" {
  bucket = aws_s3_bucket.processed.id
  policy = data.aws_iam_policy_document.processed_bucket_policy.json
}
