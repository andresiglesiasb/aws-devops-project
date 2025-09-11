resource "aws_security_group" "jenkins" {
    name = "dev-sg-jenkins"
    description = "Allows SSH from Bastion"
    vpc_id = var.vpc_id

    ingress {
        description = "SSH from Bastion"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.bastion.id]
    }

    egress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        security_groups = [aws_security_group.nginx_private.id]
    }

    tags = merge(
        var.common_tags,
        {
        Name = "dev-sg-jenkins"
        }
    )
}