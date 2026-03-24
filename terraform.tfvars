############################
# Global / Project Settings
############################

project_name = "hsbc-gamma-dev"
environment  = "dev"
aws_region   = "eu-north-1"
#profile      = "cloudreality"


############################
# Networking (VPC)
############################

vpc_cidr = "10.0.0.0/16"

azs = [
  "eu-north-1a",
  "eu-north-1b"
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
# S3 Buckets (Used by IAM)
############################

raw_images_bucket_name       = "hsbc-gamma-dev-raw-images"
processed_images_bucket_name = "hsbc-gamma-dev-processed-images"


############################
# EC2 Configuration (Future)
############################

web_instance_type = "t3.micro"
app_instance_type = "t3.micro"

key_pair_name = "hsbc-gamma-dev-key"


############################
# Auto Scaling (Optional)
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
# AMI Configuration (Future)
ami_id = "ami-0aaa636894689fa47" # Amazon Linux 3 AMI (HVM), SSD Volume Type - us-east-1
############################
