variable "bastion_sg_id" {
  type = string
}

variable "dev_public_subnet_id_1a" {
    type = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}