resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.dev_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "dev-public-rt"
    }
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.dev_vpc.id
    tags = {
      Name = "dev-private-rt"
    }
}

resource "aws_route_table_association" "pivate" {
    subnet_id = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_rt.id
}