output "lambda_function_name" {
  value = aws_lambda_function.ec2_shutdown.function_name
}

output "eventbridge_rule_name" {
  value = aws_cloudwatch_event_rule.shutdown_schedule.name
}
