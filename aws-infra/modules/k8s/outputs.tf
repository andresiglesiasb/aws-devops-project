output "k8s_instance_id" {
  description = "K8s instance ID"
  value       = aws_instance.k8s.id
}

output "k8s_private_ip" {
  description = "K8s instance private IP address"
  value       = aws_instance.k8s.private_ip
}

output "k8s_network_interface_id" {
  description = "K8s instance network interface ID"
  value       = aws_instance.k8s.primary_network_interface_id
}
