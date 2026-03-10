# Add this at the top
data "aws_caller_identity" "current" {}

# assume role for iam
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# web tier role
resource "aws_iam_role" "web_role" {
  name               = "${var.project_name}-web-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "${var.project_name}-web-role"
  }
}

# Attach CloudWatch policy to web role
resource "aws_iam_role_policy_attachment" "web_logs" {
  role       = aws_iam_role.web_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# app tier role
resource "aws_iam_role" "app_role" {
  name               = "${var.project_name}-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "${var.project_name}-app-role"
  }
}

# Attach CloudWatch policy to app role
resource "aws_iam_role_policy_attachment" "app_logs" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# s3 access policy for app role
data "aws_iam_policy_document" "app_s3_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${var.raw_bucket_name}",
      "arn:aws:s3:::${var.raw_bucket_name}/*",
      "arn:aws:s3:::${var.processed_bucket_name}",
      "arn:aws:s3:::${var.processed_bucket_name}/*"
    ]
  }

  # Add KMS permissions
  statement {
    effect = "Allow"

    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:Encrypt"
    ]

    resources = [
      "arn:aws:kms:eu-north-1:${data.aws_caller_identity.current.account_id}:key/*"
    ]
  }
}

# Create the actual IAM policy resource
resource "aws_iam_policy" "app_s3_policy" {
  name        = "${var.project_name}-app-s3-policy"
  description = "Policy for app tier to access S3 buckets"
  policy      = data.aws_iam_policy_document.app_s3_policy.json

  tags = {
    Name = "${var.project_name}-app-s3-policy"
  }
}

# Attach S3 policy to app role
resource "aws_iam_role_policy_attachment" "app_s3_attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.app_s3_policy.arn
}

# ec2 instance profiles
resource "aws_iam_instance_profile" "web_profile" {
  name = "${var.project_name}-web-instance-profile"
  role = aws_iam_role.web_role.name

  tags = {
    Name = "${var.project_name}-web-instance-profile"
  }
}

resource "aws_iam_instance_profile" "app_profile" {
  name = "${var.project_name}-app-instance-profile"
  role = aws_iam_role.app_role.name

  tags = {
    Name = "${var.project_name}-app-instance-profile"
  }
}