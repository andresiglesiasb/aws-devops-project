variable "region" {
  default = "eu-west-1"
}

variable "lambda_role_name" {
  default = "lambda-ec2-shutdown-role2"
}

variable "lambda_function_name" {
  default = "ec2AutoShutdown2"
}

variable "schedule_expression" {
  default = "cron(30 20 * * ? *)"
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
