variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "ami_id" {
  description = "AMI ID shared by every EC2 instance in the stack"
  type        = string
  default     = "ami-01f23391a59163da9"
}
