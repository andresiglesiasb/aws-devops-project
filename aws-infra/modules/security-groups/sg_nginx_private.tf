resource "aws_security_group" "nginx_private" {
    name = "dev-sg-nginx-private"
    description = "Allows SSH from Bastion and HTTP from Load Balanacer (LB)"
    vpc_id = var.vpc_id

    ingress {
        description = "SSH from Bastion"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.bastion.id] # The sg of the bastion is linked to the source of the inbound rule
    }

    ingress {
        description = "ALB to HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.alb.id]
    }

    ingress {
        description = "ALB to HTTPS"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        security_groups = [aws_security_group.alb.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(
        var.common_tags,
        {
            Name = "dev-sg-nginx-private"
        }
    )
}