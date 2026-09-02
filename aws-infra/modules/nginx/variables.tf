variable "nginx_sg_id" {
  type = string
}

variable "dev_private_subnet_id_1a" {
  type = string
}

variable "jenkins_private_ip" {
  type        = string
  description = "Private IP of Jenkins instance for NGINX reverse proxy"
  default     = ""
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "ami_id" {
  description = "AMI ID for NGINX reverse proxy (Ubuntu 22.04)"
  type        = string
}