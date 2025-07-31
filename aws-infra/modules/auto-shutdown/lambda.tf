data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/auto_shutdown.py"
  output_path = "${path.module}/lambda/auto_shutdown.zip"
}

resource "aws_lambda_function" "ec2_shutdown" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_ec2_shutdown.arn
  handler       = "ec2_shutdown.lambda_handler"
  runtime       = "python3.13"
  timeout       = 30

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}
