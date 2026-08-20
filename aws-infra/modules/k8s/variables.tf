variable "k8s_sg_id" {
  description = "Security group ID for K8s instance"
  type        = string
}

variable "dev_private_subnet_id_1a" {
  description = "Private subnet ID in availability zone 1a"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "ami_id" {
  description = "AMI ID for K3s Kubernetes node (Ubuntu 22.04)"
  type        = string
}
