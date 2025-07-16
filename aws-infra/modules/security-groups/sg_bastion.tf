resource "aws_security_group" "bastion" {
    name = "dev-sg-bastion"
    description = "Allows SSH access from your personal IP"
    vpc_id = var.vpc_id

    ingress {
        description = "SSH from my IP"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "dev-sg-bastion"
    }
}