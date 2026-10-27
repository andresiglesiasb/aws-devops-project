variable "lambda_role_name" {
  type    = string
  default = "lambda-ec2-shutdown-role2"
}

variable "lambda_function_name" {
  type    = string
  default = "ec2AutoShutdown2"
}

variable "schedule_expression" {
  type    = string
  default = "cron(30 20 * * ? *)"
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
