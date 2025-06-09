resource "aws_cloudwatch_metric_alarm" "avg_cpu" {
  alarm_name          = "AverageCPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 80
  alarm_description   = "Average CPU > 80% across 2 instances"
  actions_enabled     = true

  metric_query {
    id          = "m1"
    metric {
      namespace  = "AWS/EC2"
      metric_name = "CPUUtilization"
      dimensions = {
        InstanceId = aws_instance.private_ec2_webserver[0].id
      }
      period     = 60
      stat       = "Average"
    }
  }

  metric_query {
    id          = "m2"
    metric {
      namespace  = "AWS/EC2"
      metric_name = "CPUUtilization"
      dimensions = {
        InstanceId = aws_instance.private_ec2_webserver[1].id
      }
      period     = 60
      stat       = "Average"
    }
  }

  metric_query {
    id         = "avgCPU"
    expression = "(m1 + m2) / 2"
    label      = "Average CPU"
    return_data = true
  }

  treat_missing_data = "notBreaching"
}