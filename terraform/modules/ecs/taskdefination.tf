resource "aws_iam_role" "application_ecs_task_role" {
  name               = "application-ecs-task-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

// create execution role for the service
resource "aws_iam_role" "application_ecs_execution_role" {
  name               = "application-ecs-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  inline_policy {
    name   = "application-ecs-execution-role-policy"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "ecr:GetAuthorizationToken",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
  }
}

resource "aws_ecs_task_definition" "application" {
  family                   = "application"
  task_role_arn            = aws_iam_role.application_ecs_task_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.application_ecs_execution_role.arn
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "application",
    "image": "${var.repository_url}:latest",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${var.application_container_port},
        "hostPort": ${var.application_container_port}
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.production.name}",
        "awslogs-region": "eu-central-1",
        "awslogs-stream-prefix": "application"
        }
    }
  }
]
TASK_DEFINITION
}
