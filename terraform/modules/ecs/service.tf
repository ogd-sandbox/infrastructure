// Create a security group that alls traffic from the load balancer to the application
resource "aws_security_group" "application" {
  name        = "application"
  description = "Security group for the application"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "application_in" {
  type                     = "ingress"
  from_port                = var.application_container_port
  to_port                  = var.application_container_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.application.id
  source_security_group_id = aws_security_group.public_lb_sg.id
}

resource "aws_security_group_rule" "application_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.application.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_ecs_service" "application" {
  launch_type = "FARGATE"
  network_configuration {
    subnets = var.private_subnet_ids
    security_groups = [aws_security_group.application.id]
  }
  name            = "application"
  cluster         = aws_ecs_cluster.production.id
  task_definition = aws_ecs_task_definition.application.arn
  desired_count   = 1
  load_balancer {
    target_group_arn = aws_lb_target_group.application.arn
    container_name   = "application"
    container_port   = var.application_container_port
  }
}
