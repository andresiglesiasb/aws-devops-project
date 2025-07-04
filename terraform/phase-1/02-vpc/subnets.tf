resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.dev_vpc.id
    cidr_block = var.public_subnet_cidr
    map_public_ip_on_launch = true
    availability_zone = var.availability_zone
    tags = {
        Name = "dev-public-1a"
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.dev_vpc.id
    cidr_block = var.private_subnet_cidr
    availability_zone = var.availability_zone
    tags = {
        Name = "dev-private-1a"
    }
}
