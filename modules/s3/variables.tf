variable "project_name" {
  type = string
}

variable "raw_bucket_name" {
  type = string
}

variable "processed_images_bucket_name" {  # Keep this one (matches root variable)
  type = string
}

variable "app_role_arn" {
  type = string
}

# REMOVE this duplicate variable
# variable "processed_bucket_name" {
#   type = string
# }