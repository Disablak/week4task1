resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/fargate-app"
  retention_in_days = 7
}