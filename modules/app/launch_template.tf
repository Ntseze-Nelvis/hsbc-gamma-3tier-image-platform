resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [var.app_sg_id]

  iam_instance_profile {
    name = var.app_instance_profile
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    RAW_BUCKET       = var.raw_bucket_name
    PROCESSED_BUCKET = var.processed_bucket_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-tier"
    }
  }
}
