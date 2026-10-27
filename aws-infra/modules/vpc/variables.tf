variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "private_subnet_with_nat_cidr" {
  type    = string
  default = "10.0.3.0/24"
}

variable "publicb_subnet_cidr" {
  type    = string
  default = "10.0.4.0/24"
}

variable "availability_zone" {
  type    = string
  default = "eu-west-1a"
}

variable "availability_zoneb" {
  type    = string
  default = "eu-west-1b"
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
