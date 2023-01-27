[
  {
    "name": "application",
    "image": "${repository_url}:latest",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "environment": [
      {
        "name": "NEW_RELIC_LICENSE_KEY",
        "value": "${new_relic_license_key}"
      }
    ],
    "portMappings": [
      {
        "containerPort": ${application_container_port},
        "hostPort": ${application_container_port}
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
        "awslogs-group": "${awslogs_group}",
        "awslogs-region": "eu-central-1",
        "awslogs-stream-prefix": "application"
        }
    }
  }
]