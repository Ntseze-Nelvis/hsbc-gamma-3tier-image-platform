output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.web_tg.arn
}

output "app_target_group_arn" {
  value = aws_lb_target_group.app_tg.arn
}

output "alb_arn_suffix" {
  value = aws_lb.this.arn_suffix
}