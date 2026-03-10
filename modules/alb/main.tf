resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "application"
  internal           = false
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = var.name
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "${var.name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"

  health_check {
    path = "/"
    protocol = "HTTP"
  }
}

# NEW: App target group for port 5000
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.name}-app-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"
    port                = "5000"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "${var.name}-app-tg"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# NEW: Listener rule for app paths
resource "aws_lb_listener_rule" "app_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  condition {
    path_pattern {
      values = ["/upload*", "/health*"]
    }
  }
}