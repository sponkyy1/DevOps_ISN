output "web_server_public_ip" {
  value = aws_instance.my_frontserver.public_ip
}
output "web_server_private_ip" {
  value = aws_instance.my_backserver.private_ip
}
