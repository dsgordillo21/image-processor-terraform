output "crop_lambda_name" {
  description = "Nombre de la Lambda encargada de procesar las imagenes"
  value       = aws_lambda_function.crop.function_name
}

output "crop_lambda_arn" {
  description = "ARN de la Lambda encargada de procesar las imagenes"
  value       = aws_lambda_function.crop.arn
}

output "crop_log_group_name" {
  description = "Nombre del grupo de logs de la Lambda Crop"
  value       = aws_cloudwatch_log_group.crop.name
}

output "dlq_alarm_name" {
  description = "Nombre de la alarma de CloudWatch asociada a la DLQ"
  value       = aws_cloudwatch_metric_alarm.dlq_messages.alarm_name
}

output "dlq_sns_topic_arn" {
  description = "ARN del topic SNS utilizado por la alarma de la DLQ"
  value       = aws_sns_topic.dlq_alerts.arn
}
