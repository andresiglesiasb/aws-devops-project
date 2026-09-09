variable "jenkins_sg_id" {
  type = string
}

variable "dev_private_subnet_id_1a" {
  type = string
}
variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "ami_id" {
  type = string
}