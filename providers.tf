terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  # Backend configuration removed - will be provided via CLI
}

provider "aws" {
  region = var.aws_region
}