variable "azure_tenant_id" {
  type        = string
  description = "Azure Tenant ID for which workload identity federation will be setup"
}

variable "azure_subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "azure_resource_group_name" {
  type        = string
  description = "Azure resource group name"
}

variable "azure_resource_group_location" {
  type        = string
  description = "Azure resource group location"
}

variable "azure_application_name" {
  type        = string
  description = "AzureAD Application name"
}

variable "azure_network_name" {
  type        = string
  description = "Azure network name which will be created"
}

variable "azure_subnet_name" {
  type        = string
  description = "Azure subnet name which will be created"
}

variable "azure_vm_name" {
  type        = string
  description = "Azure VM name"
}

variable "azure_vm_network_interface_name" {
  type        = string
  description = "Azure network interface which will be attached to VM"
}

variable "azure_vm_ssh_private_key_name" {
  type        = string
  description = "Azure VM ssh private key name"
}

variable "azure_vm_admin_user_name" {
  type        = string
  description = "Azure VM admin user name"
}

variable "azure_ad_group_name" {
  type        = string
  description = "Azure AD group name"
}

variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID in which workload identity pool will be created"
}


variable "gcp_workload_identity_pool_name" {
  type        = string
  description = "Workload Identity Pool name / ID"
}

variable "gcp_workload_identity_pool_display_name" {
  type        = string
  description = "Workload Identity Pool display name"
}

variable "gcp_workload_identity_pool_provider_id" {
  type        = string
  description = "Workload Identity Pool Provider name / ID"
}

variable "gcp_workload_identity_pool_provider_attribute_mappings" {
  type        = map(string)
  description = "Workload Identity Pool Provider attribute mappings"
}

variable "gcp_service_accounts" {
  type = list(object({
    sa_name : string
    sa_roles : list(string)
    members : list(string)
  }))
  description = "GCP service accounts to create with roles and members (extern identifiers)"
  default     = []
}