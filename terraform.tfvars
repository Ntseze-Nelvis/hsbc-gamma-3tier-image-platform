############################
# Global / Project Settings
############################

project_name = "hsbc-gamma-v2"
environment  = "dev"
aws_region   = "us-east-1"

############################
# Networking (VPC)
############################

vpc_cidr = "10.0.0.0/16"

azs = [
  "us-east-1a",
  "us-east-1b"
]

public_subnets = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnets = [
  "10.0.3.0/24",
  "10.0.4.0/24"
]

############################
# Application Ports
############################

web_port = 80
app_port = 5000

############################
# S3 Buckets - Unique names
############################

raw_images_bucket_name       = "hsbc-gamma-v2-raw"
processed_images_bucket_name = "hsbc-gamma-v2-processed"

############################
# EC2 Configuration
############################

web_instance_type = "t3.micro"
app_instance_type = "t3.micro"
key_pair_name     = "hsbc-gamma-v2-key"

############################
# Auto Scaling
############################

web_desired_capacity = 2
web_min_size         = 1
web_max_size         = 3

app_desired_capacity = 2
app_min_size         = 1
app_max_size         = 3

############################
# Logging & Monitoring
############################

enable_cloudwatch_logs = true

############################
# AMI Configuration for us-east-1
# Amazon Linux 2023 AMI
ami_id = "ami-02dfbd4ff395f2a1b"
