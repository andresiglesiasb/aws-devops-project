output "vpc_id" {
    value = aws_vpc.dev_vpc.id
}

output "dev_igw" {
    value = aws_internet_gateway.igw.id
}

output "dev_public_subnet_id_1a" {
    value = aws_subnet.public_subnet.id
}

output "dev_private_subnet_id_1a" {
    value = aws_subnet.private_subnet.id
}

output "private_route_table_id" {
    value = aws_route_table.private_rt.id
}

output "dev_public_subnet_id_1b" {
    value = aws_subnet.public_subnet_b.id
}