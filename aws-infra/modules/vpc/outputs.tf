output "vpc_id" {
    value = aws_vpc.dev_vpc.id
}

output "dev_igw" {
    value = aws_internet_gateway.igw.id
}

output "dev_public_subnet_id_1a" {
    value = aws_subnet.public_subnet.id
}