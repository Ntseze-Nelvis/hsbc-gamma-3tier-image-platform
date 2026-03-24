variable "ami_id" {
  type        = string
  description = "ami id"
}

variable "instance_type" {
  type        = string
  description = "instance type"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "list of private subnet ids"
}

variable "app_sg_id" {
  type        = string
  description = "app security group id"
}

variable "raw_bucket_name" {
  type        = string
  description = "raw s3 bucket name"
}

variable "processed_bucket_name" {
  type        = string
  description = "processed s3 bucket name"
}

variable "app_instance_profile" {
  type        = string
  description = "app instance profile name"
}

# NEW: Add target group ARN variable
variable "target_group_arn" {
  description = "ARN of the app target group"
  type        = string
}
variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}
