resource "aws_kms_key" "production" {
  description             = "production"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "production" {
  name = "production"
}

resource "aws_ecs_cluster" "production" {
  name = "production"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.production.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.production.name
      }
    }
  }
}
