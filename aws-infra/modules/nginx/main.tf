resource "aws_instance" "nginx" {
  ami = "ami-01f23391a59163da9"
  instance_type = "t2.micro"
  key_name = "dev-key-bastion"
  subnet_id = var.dev_private_subnet_id_1a
  associate_public_ip_address = false
  vpc_security_group_ids = [var.nginx_sg_id]

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx
    systemctl start nginx
    systemctl enable nginx
    EOF


  tags = merge(
    var.common_tags,
    {
      Name = "dev-nginx-ec2"
    }
  )
  
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    delete_on_termination = true
  }
}