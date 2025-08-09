resource "aws_instance" "nat" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = var.key_name

  tags = merge(
    var.common_tags,
    {
      Name = "dev-bgateway-ec2"
    }
  )

  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              sysctl -w net.ipv4.ip_forward=1
              echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
              iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
              apt update -y
              apt install -y iptables-persistent
              netfilter-persistent save
              EOF
}
