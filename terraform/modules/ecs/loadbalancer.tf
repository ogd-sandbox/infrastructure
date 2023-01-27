resource "aws_security_group" "public_lb_sg" {
  name        = "public-lb-sg"
  description = "Security group for the load balancer"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "public_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.public_lb_sg.id
}

resource "aws_security_group_rule" "public_in_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_lb_sg.id
}

resource "aws_security_group_rule" "public_in_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_lb_sg.id
}

resource "aws_lb" "public" {
  name               = "public"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_lb_sg.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = true
}

resource "aws_lb_target_group" "application" {
  name     = "application"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path     = "/api/v1/health"
    port     = var.application_container_port
    protocol = "HTTP"
  }
  target_type = "ip"
  deregistration_delay = 15
}

resource "aws_lb_listener" "public_redirect" {
  load_balancer_arn = aws_lb.public.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "public_https" {
  load_balancer_arn = aws_lb.public.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:eu-central-1:343180856461:certificate/3d3749e3-342f-4f1a-8195-d6e90e3db2b1"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "503"
    }
  }
}

resource "aws_lb_listener_rule" "application" {
  listener_arn = aws_lb_listener.public_https.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application.arn
  }

  condition {
    host_header {
      values = ["hi.gazidizdaroglu.com"]
    }
  }
}
