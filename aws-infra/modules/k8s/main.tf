resource "aws_instance" "k8s" {
  ami                         = var.ami_id
  instance_type               = "t2.small"
  key_name                    = "dev-key-bastion"
  subnet_id                   = var.dev_private_subnet_id_1a
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.k8s_sg_id]

  tags = merge(
    var.common_tags,
    {
      Name = "dev-k8s-ec2"
    }
  )

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }
}
