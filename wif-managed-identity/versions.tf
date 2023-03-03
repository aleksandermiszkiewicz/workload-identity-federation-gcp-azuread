terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.21.0"
    }
    azuredevops = {
      source = "microsoft/azuredevops"
      version = ">=0.1.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }
  required_version = ">= 1.1.0"
}

provider "google" {
  project = var.gcp_project_id
}

provider "azuredevops" {
  org_service_url = "https://dev.azure.com/alemisazure"
  personal_access_token = "4kch7ww2lj26zzptmn5jdcu7rb4np3rvnuxhl6n2mbyecdk74uvq"
}

provider "azurerm" {
  features {}
  tenant_id = var.azure_tenant_id
}

provider "azuread" {
  tenant_id = var.azure_tenant_id
}