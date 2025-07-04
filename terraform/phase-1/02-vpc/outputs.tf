output "vpc_id" {
    value = aws_vpc.dev_vpc.id
}

output "dev_igw" {
    value = aws_internet_gateway.igw.id
}