resource "aws_autoscaling_group" "web_asg" {
  name                = "${var.project_name}-web-asg"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = var.public_subnet_ids

  target_group_arns = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-web-instance"
    propagate_at_launch = true
  }
}
