variable "resource_group_location" {
  type        = string
  description = "Azure Resource Group location"
  default     = "northeurope"
}

variable "resource_group_name" {
  type        = string
  description = "Azure Resource Group name"
  default     = "gcp-wif-test"
}

variable "network_name" {
  type        = string
  description = "Azure network name"
  default     = "gcp-wif-network"
}

variable "network_addresses_ranges" {
  type        = list(string)
  description = "Azure network addresses ranges"
  default     = ["10.0.0.0/24"]
}

variable "subnet_name" {
  type        = string
  description = "Azure subnet name"
  default     = "gcp-wif-subnet"
}

variable "subnet_addresses_ranges" {
  type        = list(string)
  description = "Azure subnet addresses ranges"
  default     = ["10.0.0.0/28"]
}

variable "vm_public_ip_name" {
  type        = string
  description = "Azure VM public IP name"
  default     = "gcp-wif-ip"
}

variable "ingress_ssh_allow_rule_name" {
  type        = string
  description = "Azure Ingress SSH allow rule name"
  default     = "gcp-wif-ssh-allow-rule"
}

variable "vm_network_interface_name" {
  type        = string
  description = "Azure network interface attached to VM"
  default     = "gcp-wif-ni"
}

variable "vm_name" {
  type        = string
  description = "Azure VM created for tests purposes"
  default     = "gcp-wif-vm"
}

variable "vm_admin_user_name" {
  type        = string
  description = "Azure VM admin user name"
  default     = "adminuser"
}

variable "vm_ssh_private_key_file_name" {
  type        = string
  description = "Azure VM ssh private key file name"
  default     = "az_vm.pem"
}

variable "vm_identities" {
  type = list(object({
    type           = string
    identities_ids = set(string)
  }))
  description = "Azure VM identities with which VM should be created. Identities types: SystemAssigned, UserAssigned, SystemAssigned,UserAssigned"
  default     = []
}