terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
# For GitHub Actions: uses AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY from environment
# For local development: uncomment the profile line
provider "aws" {
  region = var.aws_region
  # profile = "cloudreality"  # Uncomment for local development
}
