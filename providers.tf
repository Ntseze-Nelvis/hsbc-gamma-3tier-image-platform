terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  
  # Backend configuration - will be configured via CI/CD
  backend "s3" {
    # Values will be provided by GitLab CI/CD variables
    bucket = ""
    key    = ""
    region = ""
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}
