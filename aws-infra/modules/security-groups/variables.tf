variable "vpc_id" {
  type = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}