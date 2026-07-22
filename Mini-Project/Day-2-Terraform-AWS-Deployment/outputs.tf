output "public_ip" {
  description = "Public IP of the EC2 Instance"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "Public DNS of the EC2 Instance"
  value       = aws_instance.web.public_dns
}