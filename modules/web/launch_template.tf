resource "aws_launch_template" "web_lt" {
  name_prefix   = "web-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [var.web_sg_id]

  user_data = base64encode(file("${path.module}/user_data.sh"))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "web-tier"
    }
  }
}
