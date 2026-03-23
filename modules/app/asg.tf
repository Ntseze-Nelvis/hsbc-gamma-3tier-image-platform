resource "aws_autoscaling_group" "app_asg" {
  name             = "app-asg"
  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  vpc_zone_identifier = var.private_subnet_ids

  # NEW: Add target group attachment
  target_group_arns = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "app-asg-instance"
    propagate_at_launch = true
  }
}