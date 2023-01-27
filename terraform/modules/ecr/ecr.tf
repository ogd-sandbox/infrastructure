resource "aws_ecr_repository" "application" {
  name                 = "application"
}

output "application_repository_url" {
  value = aws_ecr_repository.application.repository_url
}