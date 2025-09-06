resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.dev_vpc.id
    cidr_block = var.public_subnet_cidr
    map_public_ip_on_launch = true
    availability_zone = var.availability_zone
    tags = merge(
        var.common_tags,
        {
            Name = "dev-public-1a"
        }
    )
}

resource "aws_subnet" "public_subnet_b" {
    vpc_id = aws_vpc.dev_vpc.id
    cidr_block = var.publicb_subnet_cidr
    map_public_ip_on_launch = true
    availability_zone = var.availability_zoneb
    tags = merge(
        var.common_tags,
        {
            Name = "dev-public-1b"
        }
    )
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.dev_vpc.id
    cidr_block = var.private_subnet_cidr
    availability_zone = var.availability_zone
    tags = merge(
        var.common_tags,
        {
            Name = "dev-private-1a"
        }
    )
}

resource "aws_subnet" "private_subnet_with_nat" {
    vpc_id = aws_vpc.dev_vpc.id
    cidr_block = var.private_subnet_with_nat_cidr
    availability_zone = var.availability_zone
    tags = merge(
        var.common_tags,
        {
            Name = "dev-private-with-nat-1a"
        }
    )
}
