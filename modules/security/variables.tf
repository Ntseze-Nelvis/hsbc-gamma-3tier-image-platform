variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "hsbc-gamma-dev"
}

variable "raw_bucket_name" {
  description = "Raw images bucket name"
  type        = string
}

variable "processed_bucket_name" {
  description = "Processed images bucket name"
  type        = string
}


