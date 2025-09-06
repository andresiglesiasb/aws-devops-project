# -------------------------------
# IAM OUTPUTS
# -------------------------------
output "access_key_id" {
  value = module.iam.access_key_id
}

output "secret_access_key" {
  value = module.iam.secret_access_key
  sensitive = true # Ensures that sensitive information is not displayed in the CLI or logs.
}

output "console_password" {
  value = module.iam.console_password
  sensitive = true # Ensures that sensitive information is not displayed in the CLI or logs.
}

# -------------------------------
# VPC OUTPUTS
# -------------------------------
output "vpc_id" {
    value = module.vpc.vpc_id
}

output "dev_igw" {
    value = module.vpc.dev_igw
}

output "dev_public_subnet_id_1a" {
    value = module.vpc.dev_public_subnet_id_1a
}

# -------------------------------
# SECURITY GROUPS OUTPUTS
# -------------------------------
output "bastion_sg_id" {
  value = module.security-groups.bastion_sg_id
}

output "nginx_private_sg_id" {
  value = module.security-groups.nginx_private_sg_id
}

output "alb_sg_id" {
  value = module.security-groups.alb_sg_id
}

# -------------------------------
# BASTION OUTPUTS
# -------------------------------
output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}

# -------------------------------
# AUTO-SHUTDOWN OUTPUTS
# -------------------------------
output "lambda_function_name" {
  value = module.auto-shutdown.lambda_function_name
}

output "eventbridge_rule_name" {
  value = module.auto-shutdown.eventbridge_rule_name
}

# -------------------------------
# INSTANCE-GATEWAY OUTPUTS
# -------------------------------
output "nat_instance_id" {
  value = module.nat_ec2_gateway.nat_instance_id
}

output "nat_private_ip" {
  value = module.nat_ec2_gateway.nat_private_ip
}

output "nat_public_ip" {
  value = module.nat_ec2_gateway.nat_public_ip
}

output "nat_network_interface_id" {
  value = module.nat_ec2_gateway.nat_network_interface_id
}

# -------------------------------
# NGINX OUTPUTS
# -------------------------------
output "nginx_private_ip" {
  value = module.nginx.nginx_private_ip
}

output "nginx_instance_id" {
    value = module.nginx.nginx_instance_id
}

# -------------------------------
# ALB OUTPUTS
# -------------------------------
output "alb_dns_name" {
  value = module.alb.alb_dns_name
}
