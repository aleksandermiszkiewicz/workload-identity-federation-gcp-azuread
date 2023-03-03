variable "project_id" {
  type        = string
  description = "GCP Project ID in which workload identity pool will be created"
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure Tenant ID for which workload identity federation will be setup"
}

variable "workload_identity_pool_name" {
  type        = string
  description = "Workload Identity Pool name / ID"
}

variable "workload_identity_pool_description" {
  type        = string
  description = "Workload Identity Pool description"
  default     = "Workload identity pool managed by terraform"
}

variable "workload_identity_pool_display_name" {
  type        = string
  description = "Workload Identity Pool display name"
}

variable "workload_identity_pool_provider_id" {
  type        = string
  description = "Workload Identity Pool Provider name / ID"
}

variable "workload_identity_pool_provider_description" {
  type        = string
  description = "Workload Identity Pool Provider description"
  default     = "Workload identity pool provider managed by terraform"
}

variable "workload_identity_pool_provider_allowed_audiences" {
  type        = list(string)
  description = "Workload Identity Pool Provider allowed audiences"
}

variable "workload_identity_pool_provider_attribute_mappings" {
  type        = map(string)
  description = "Workload Identity Pool Provider attribute mappings"
}