variable "name" {
    description = "The name of the ALB"
    type = string
}

variable "vpc_id" {
    description = "The ID of the VPC where the ALB will be deployed"
    type = string       
}

variable "public_subnet_ids" {
    default = [ "value" ]
  type = list(string)
}

variable "alb_sg_id" {
    description = "The ID of the security group for the ALB"
  type = string
}


