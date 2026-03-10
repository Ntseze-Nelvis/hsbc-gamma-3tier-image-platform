output "alb_sg_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "web_sg_id" {
  description = "The ID of the web tier security group"
  value       = aws_security_group.web_sg.id  # Changed from ec2_sg to web_sg
}

output "app_sg_id" {
  description = "The ID of the app tier security group"
  value       = aws_security_group.app_sg.id
}

output "web_instance_profile_name" {
  description = "The name of the web tier instance profile"
  value       = aws_iam_instance_profile.web_profile.name
}

output "app_instance_profile_name" {
  description = "The name of the app tier instance profile"
  value       = aws_iam_instance_profile.app_profile.name
}

output "app_role_arn" {
  description = "app role arn"
  value       = aws_iam_role.app_role.arn
}

output "web_role_name" {
  description = "web role name"
  value       = aws_iam_role.web_role.name
}

output "app_role_name" {
  description = "app role name"
  value       = aws_iam_role.app_role.name
}