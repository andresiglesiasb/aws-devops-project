resource "aws_vpc" "dev_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    tags = {
      Name = "dev-vpc"
    }
}