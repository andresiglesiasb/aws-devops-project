output "nat_instance_id" {
  value = aws_instance.nat.id
}

output "nat_private_ip" {
  value = aws_instance.nat.private_ip
}

output "nat_public_ip" {
  value = aws_instance.nat.public_ip
}

output "nat_network_interface_id" {
  value = aws_instance.nat.primary_network_interface_id
}