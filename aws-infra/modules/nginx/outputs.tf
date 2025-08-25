output "nginx_private_ip" {
    value = aws_instance.nginx.private_ip
}

output "nginx_instance_id" {
    value = aws_instance.nginx.id
}
