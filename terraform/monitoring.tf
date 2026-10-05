resource "aws_cloudwatch_log_group" "crop" {
  name              = "/aws/lambda/${aws_lambda_function.crop.function_name}"
  retention_in_days = 7

  tags = {
    Name        = "${local.name_prefix}-crop-logs"
    Environment = local.environment
  }
}

resource "aws_sns_topic" "dlq_alerts" {
  name = "${local.name_prefix}-dlq-alerts"

  tags = {
    Name        = "${local.name_prefix}-dlq-alerts"
    Environment = local.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "${local.name_prefix}-dlq-messages"
  alarm_description   = "Alarma cuando existen mensajes visibles en la DLQ"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1

  metric_name = "ApproximateNumberOfMessagesVisible"
  namespace   = "AWS/SQS"
  period      = 60
  statistic   = "Maximum"

  dimensions = {
    QueueName = aws_sqs_queue.image_dlq.name
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.dlq_alerts.arn
  ]

  tags = {
    Name        = "${local.name_prefix}-dlq-alarm"
    Environment = local.environment
  }
}
