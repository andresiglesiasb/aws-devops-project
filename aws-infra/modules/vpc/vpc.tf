resource "aws_vpc" "dev_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = merge(
    var.common_tags,
    {
      Name = "dev-vpc"
    }
  )
}