# Web Tier CPU Alarm
resource "aws_cloudwatch_metric_alarm" "web_cpu_high" {
  alarm_name          = "web-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = var.web_asg_name
  }
}

# App Tier CPU Alarm
resource "aws_cloudwatch_metric_alarm" "app_cpu_high" {
  alarm_name          = "app-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = var.app_asg_name
  }
}
