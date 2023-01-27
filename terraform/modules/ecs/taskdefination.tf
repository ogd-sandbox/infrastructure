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

data "aws_ssm_parameter" "by_name_new_relic_license_key" {
  name = "/global/NEW_RELIC_LICENSE_KEY"
}

data "template_file" "task_template_application" {
  template = file("../modules/ecs/templates/applicationtaskdefination.json.tpl")

  vars = {
    repository_url             = var.repository_url
    new_relic_license_key      = data.aws_ssm_parameter.by_name_new_relic_license_key.value
    application_container_port = var.application_container_port
    awslogs_group              = "${aws_cloudwatch_log_group.production.name}"
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
  container_definitions    = data.template_file.task_template_application.rendered
}
