terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  
  # ✅ CORRECT: Remote state storage
  backend "s3" {
    bucket         = "hsbc-gamma-dev-terraform-state"
    key            = "3tier-image-platform/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region
}