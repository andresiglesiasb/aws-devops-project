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
    volume_type = "gp3"
    volume_size = var.volume_size
    delete_on_termination = true
  }

  # The following script configures the EC2 instance to act as a NAT gateway by:
  # 1. Enabling IPv4 packet forwarding
  # 2. Making the above configuration persistent across reboots by adding 'net.ipv4.ip_forward=1' to /etc/sysctl.conf
  # 3. Configuring NAT masquerading on the eth0 interface to allow other instances to access the Internet
  # 4. Updating package lists and installing iptables-persistent
  # 5. Saving the current iptables rules for automatic restoration after reboot

  user_data = <<-EOF
              #!/bin/bash
              sysctl -w net.ipv4.ip_forward=1
              echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
              iptables -t nat -A POSTROUTING -o enX0 -s 10.0.2.0/24 -j MASQUERADE
              apt update -y
              apt install -y iptables-persistent
              netfilter-persistent save
              EOF
}
