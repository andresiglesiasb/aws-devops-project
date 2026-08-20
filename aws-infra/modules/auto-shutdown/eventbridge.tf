resource "aws_cloudwatch_event_rule" "shutdown_schedule" {
  name                = "shutdown-ec2-daily"
  description         = "Shutdowns all ec2 instances at exact time"
  schedule_expression = var.schedule_expression
  tags                = var.common_tags
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.shutdown_schedule.name
  target_id = "lambda-ec2-shutdown"
  arn       = aws_lambda_function.ec2_shutdown.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_shutdown.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.shutdown_schedule.arn
}
