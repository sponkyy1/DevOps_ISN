output "web_server_public_ip" {
  value = module.ec2_instance.web_server_public_ip
}
output "web_server_private_ip" {
  value = module.ec2_instance.web_server_private_ip
}