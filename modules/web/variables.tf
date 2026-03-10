variable "ami_id" {
    description = "ami id"
    type = string
}

variable "instance_type" {
    description = "instance type"
    type = string
    default = "t3.micro"

}
variable "public_subnet_ids" {
  type        = list(string)
  description = "list of public subnet ids"
}

variable "web_sg_id" {
  description = "web security group id"
  type = string
}

variable "target_group_arn" {
  description = "target group arn"
  type = string
}


