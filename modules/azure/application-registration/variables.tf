variable "application_name" {
  type        = string
  description = "AzureAD Application name"
}

variable "application_sign_in_audience" {
  type        = string
  description = "The Microsoft account types that are supported for the current application e.g. AzureADMyOrg"
  default     = "AzureADMyOrg"
}

variable "resource_group" {
  type        = string
  description = "Azure resource group name"
}