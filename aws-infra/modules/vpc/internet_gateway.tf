resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.dev_vpc.id
    tags = merge(
        var.common_tags,
        {
            Name = "dev-igw"
        }
    )
}