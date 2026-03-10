# root module variables.tf
variable "project_name" {
  description = "The name of the project"
  type        = string
}
variable "environment" {
  description = "The environment name"
  type        = string
}
variable "aws_region" {
  description = "The AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}
variable "azs" {
  description = "The availability zones"
  type        = list(string)
}
variable "public_subnets" {
  description = "The public subnets"
  type        = list(string)
}
variable "private_subnets" {
  description = "The private subnets"
  type        = list(string)
}

variable "raw_images_bucket_name" {
  description = "The name of the raw images S3 bucket"
  type        = string
}
variable "processed_images_bucket_name" {
  description = "The name of the processed images S3 bucket"
  type        = string
}
variable "web_instance_type" {
  description = "The instance type for web tier EC2 instances"
  type        = string
}
variable "app_instance_type" {
  description = "The instance type for app tier EC2 instances"
  type        = string
}

variable "web_port" {
  description = "The port for the web tier"
  type        = number
}

variable "app_port" {
  description = "The port for the app tier"
  type        = number
}

variable "key_pair_name" {
  description = "The name of the EC2 key pair"
  type        = string
}

variable "web_desired_capacity" {
  description = "The desired capacity for the web tier ASG"
  type        = number
}

variable "web_min_size" {
  description = "The minimum size for the web tier ASG"
  type        = number
}

variable "web_max_size" {
  description = "The maximum size for the web tier ASG"
  type        = number
}

variable "app_max_size" {
  description = "The maximum size for the app tier ASG"
  type        = number
}

variable "enable_cloudwatch_logs" {
  description = "To enable cloudwatch_logs"
  type        = bool
}

variable "app_min_size" {
  description = "The app min size"
  type        = number
}


variable "app_desired_capacity" {
  description = "The desired app capacity"
  type        = number
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances"
  type        = string
}









