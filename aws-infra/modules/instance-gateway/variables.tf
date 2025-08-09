variable "ami_id" {
  type        = string
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  type        = string
}

variable "security_group_id" {
  type        = string
}

variable "key_name" {
  type        = string
}

variable "name" {
  type        = string
  default     = "dev-instance-ec2"
}

variable "volume_size" {
  type        = number
  default     = 8
}

variable "common_tags" {
  type    = map(string)
  default = {}
}