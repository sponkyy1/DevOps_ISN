variable "subscription_id" {}

variable "serviceprinciple_id" {}

variable "serviceprinciple_key" {}

variable "tenant_id" {}

variable "ssh_key" {}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "West Europe"
}
