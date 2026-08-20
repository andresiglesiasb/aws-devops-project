output "access_key_id" {
  value = aws_iam_access_key.access_key.id
}

output "secret_access_key" {
  value     = aws_iam_access_key.access_key.secret
  sensitive = true # Ensures that sensitive information is not displayed in the CLI or logs.
}

output "console_password" {
  value     = aws_iam_user_login_profile.login_profile.password
  sensitive = true # Ensures that sensitive information is not displayed in the CLI or logs.
}