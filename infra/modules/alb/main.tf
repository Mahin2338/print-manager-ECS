resource "aws_lb" "main" {
name               = "url-shortener-alb"
internal           = false
load_balancer_type = "application"
security_groups    = [var.alb_sg_id]
subnets            = var.public_subnet_ids

tags = {
Name = "url-shortener-alb"
}
}

resource "aws_lb_target_group" "blue" {
name        = "url-shortener-blue"
port        = 8080
protocol    = "HTTP"
target_type = "ip"
vpc_id      = var.vpc_id


lifecycle {
  create_before_destroy = true
}

health_check {
enabled             = true
healthy_threshold   = 2
unhealthy_threshold = 2
interval            = 30
path                = "/health"
protocol            = "HTTP"
timeout             = 5
matcher             = "200"
}

tags = {
Name = "url-shortener-blue-tg"
}
}



resource "aws_alb_listener" "name" {
  load_balancer_arn = aws_lb.main.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}