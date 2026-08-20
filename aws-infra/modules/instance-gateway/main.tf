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
      Name = "dev-gateway-ec2"
    }
  )

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.volume_size
    delete_on_termination = true
  }

  # Configures NAT masquerading at boot, detecting the outbound interface dynamically
  # (avoids hardcoding eth0 vs enX0 which varies by instance type/generation).
  user_data = <<-EOF
    #!/bin/bash
    sysctl -w net.ipv4.ip_forward=1
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    WAN_IF=$(ip route show default | awk '{print $5}' | head -n1)
    iptables -t nat -A POSTROUTING -o "$WAN_IF" -s 10.0.2.0/24 -j MASQUERADE
    apt-get update -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent
    netfilter-persistent save
    EOF
}
