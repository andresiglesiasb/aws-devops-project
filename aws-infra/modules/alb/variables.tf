variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}
variable "target_instance_ids" {
  type = list(string)
}
