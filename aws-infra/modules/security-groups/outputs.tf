output "bastion_sg_id" {
  value = aws_security_group.bastion.id
}

output "nginx_private_sg_id" {
  value = aws_security_group.nginx_private.id
}

output "gateway_sg_id" {
  value = aws_security_group.gateway.id
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "k8s_sg_id" {
  value = aws_security_group.k8s.id
}

output "jenkins_sg_id" {
  value = aws_security_group.jenkins.id
}
