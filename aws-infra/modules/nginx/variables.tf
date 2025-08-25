variable "nginx_sg_id" {
  type = string
}

variable "dev_private_subnet_id_1a" {
    type = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}