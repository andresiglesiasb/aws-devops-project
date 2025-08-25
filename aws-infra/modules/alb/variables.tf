variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {}

variable "public_subnets" {
  type = list(string)
}

variable "alb_sg_id" {}
variable "target_instance_ids" {
  type = list(string)
}
