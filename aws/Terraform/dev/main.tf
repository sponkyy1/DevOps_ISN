#----------------------------------------------------
# My Terraform 
#
# Made by Yurii Zhuravchak
#----------------------------------------------------
module "ec2_instance" {
  source           = "./modules/ec-2/"
  path_playbook    = var.path_playbook
  path_playbook_1  = var.path_playbook_1
  path_private_key = var.path_private_key
  docker_file      = var.docker_file
  html_file        = var.html_file
  public_key       = var.public_key
  private_key      = var.private_key
}