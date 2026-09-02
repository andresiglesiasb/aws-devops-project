resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = "dev-key"
  subnet_id                   = var.dev_public_subnet_id_1a
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.bastion_sg_id]

  tags = merge(
    var.common_tags,
    {
      Name = "dev-bastion-ec2"
    }
  )

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }
}