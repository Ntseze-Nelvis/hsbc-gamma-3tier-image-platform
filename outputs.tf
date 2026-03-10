output "raw_bucket_arn" {
  value = module.s3.raw_bucket_arn
}

output "processed_bucket_arn" {
  value = module.s3.processed_bucket_arn
}

output "kms_key_arn" {
  value = module.s3.kms_key_arn
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "web_asg_name" {
  value = module.web.web_asg_name # Fixed: module.web, not module.web_asg
}

output "app_asg_name" {
  value = module.app.app_asg_name # Fixed: module.app, not module.app_asg
}