variable "access_key_id" {
  type = string
}

variable "secret_access_key" {
  type = string
}

variable "region" {
  default = "eu-central-1"
}

variable "path_playbook" {
  type = string
}
variable "path_playbook_1" {
  type = string
}
variable "path_private_key" {}
variable "docker_file" {}
variable "html_file" {}
variable "public_key" {}
variable "private_key" {}