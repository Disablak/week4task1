resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/fargate-app"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "django_migration" {
  name              = "/ecs/django-migration"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "django_create_user" {
  name              = "/ecs/django-create-superuser"
  retention_in_days = 7
}