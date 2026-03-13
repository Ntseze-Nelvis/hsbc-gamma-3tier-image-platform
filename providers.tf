terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "eu-north-1"
  profile = "cloudreality"
}

# Configure the AWS Provider for the default profile
# This is used for the S3 backend to store the Terraform state file.
# THIS IS EDUCATIONAL, C'EST UN MOIYEN DE VISUALISE