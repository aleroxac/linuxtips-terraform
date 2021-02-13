output "private_key" {
  value = tls_private_key.private_key.private_key_pem
}

output "public_ip" {
  value = aws_instance.ec2_instance.public_ip
}
