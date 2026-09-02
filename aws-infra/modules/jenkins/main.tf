# -----------------------------------------------------------------------------
# Jenkins EC2 Instance
# -----------------------------------------------------------------------------
# This instance is created with Terraform and automatically installs
# Java and Jenkins (service enabled and running on port 8080).
#
# IMPORTANT:
# - Terraform does NOT perform the initial Jenkins unlock or create the
#   admin user. You must do that manually as it is explained in the .md
# - The "/jenkins" URL prefix and Nginx reverse-proxy configuration are
#   also NOT handled by Terraform; these steps must be done manually following the steps.
# -----------------------------------------------------------------------------

resource "aws_instance" "jenkins" {
  ami = "ami-01f23391a59163da9"
  instance_type = "t2.micro"
  key_name = "dev-key-bastion"
  subnet_id = var.dev_private_subnet_id_1a
  associate_public_ip_address = false
  vpc_security_group_ids = [var.jenkins_sg_id]

  user_data = file("${path.module}/user_data_jenkins.sh")

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "dev-jenkins-ec2"
  }
}
