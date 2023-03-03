# Azure resources
resource "azurerm_resource_group" "az_rg" {
  name     = var.azure_resource_group_name
  location = var.azure_resource_group_location
}

module "azure-application" {
  source           = "../modules/azure/application-registration"
  application_name = var.azure_application_name
  resource_group   = azurerm_resource_group.az_rg.name
  depends_on       = [azurerm_resource_group.az_rg]
}

module "azure-service-principal" {
  source         = "../modules/azure/service-principal"
  application_id = module.azure-application.azuread_application_id
  resource_group = azurerm_resource_group.az_rg.name
  depends_on     = [azurerm_resource_group.az_rg]
}

module "azure-configured-resources-with-vm" {
  source                       = "../modules/azure/configured-resources-with-vm"
  resource_group_name          = azurerm_resource_group.az_rg.name
  resource_group_location      = azurerm_resource_group.az_rg.location
  network_name                 = var.azure_network_name
  subnet_name                  = var.azure_subnet_name
  vm_name                      = var.azure_vm_name
  vm_network_interface_name    = var.azure_vm_network_interface_name
  vm_ssh_private_key_file_name = var.azure_vm_ssh_private_key_name
  vm_admin_user_name           = var.azure_vm_admin_user_name
  vm_identity_type             = "SystemAssigned"
  depends_on                   = [azurerm_resource_group.az_rg]
}

# Creation of Azure AD group and assignment Application service principal to the group
resource "azuread_group" "azuread-group" {
  display_name     = var.azure_ad_group_name
  mail_enabled     = false
  security_enabled = true
}

resource "azuread_group_member" "azuread-group-member" {
  group_object_id  = azuread_group.azuread-group.object_id
  member_object_id = module.azure-service-principal.azuread_service_principal_object_id
}

resource "azurerm_role_assignment" "assign_group_reader_role_to_rg" {
  principal_id         = azuread_group.azuread-group.object_id
  scope                = azurerm_resource_group.az_rg.id
  role_definition_name = "Reader"
}

# GCP resources
data "google_project" "gcp_project" {
  project_id = var.gcp_project_id
}

module "gcp-workload-identity-federation" {
  source = "../modules/gcp/workload-identity-federation"

  project_id      = var.gcp_project_id
  azure_tenant_id = var.azure_tenant_id

  workload_identity_pool_name         = var.gcp_workload_identity_pool_name
  workload_identity_pool_display_name = var.gcp_workload_identity_pool_display_name

  workload_identity_pool_provider_id                = var.gcp_workload_identity_pool_provider_id
  workload_identity_pool_provider_allowed_audiences = [
    "api://${module.azure-application.azuread_application_id}"
  ]
  workload_identity_pool_provider_attribute_mappings = var.gcp_workload_identity_pool_provider_attribute_mappings
}

module "gcp-service-account" {
  source = "../modules/gcp/service-account"

  project_id       = var.gcp_project_id
  service_accounts = [
    {
      sa_name  = "test1-no-wif-sa"
      sa_roles = ["roles/compute.viewer"]
      wif      = false
    },
    {
      sa_name  = "test1-wif-sa"
      sa_roles = ["roles/compute.viewer"]
      # service account can be used only by the identity which has only a one identity defined in JWT sub claim
      member   = "principal://iam.googleapis.com/${module.gcp-workload-identity-federation.workload_identity_pool_name}/subject/${module.azure-service-principal.azuread_service_principal_object_id}"
      wif      = true
    },
    {
      sa_name  = "test2-wif-sa"
      sa_roles = ["roles/compute.viewer"]
      # service account can be used only by the identity which has only a one identity defined in JWT sub claim
      member   = "principalSet://iam.googleapis.com/${module.gcp-workload-identity-federation.workload_identity_pool_name}/group/${azuread_group.azuread-group.object_id}"
      wif      = true
    }
  ]
}

# generate script to fetch final access token
resource "local_file" "generate_fetching_access_token_scripts" {
  for_each = toset(module.gcp-service-account.service_accounts_emails)
  content  = templatefile(
    "${path.module}/templates/fetching-access-token.sh.tpl",
    {
      gcp_workload_identity_pool_provider_name = module.gcp-workload-identity-federation.workload_identity_pool_provider_name
      gcp_service_account_email                = each.value

      azure_tenant_id                = var.azure_tenant_id
      azure_application_id           = module.azure-application.azuread_application_id
      azure_service_principal_secret = module.azure-service-principal.azuread_service_principal_secret
    }
  )
  filename = "${path.module}/scripts/fetching-access-token-${trimsuffix(each.value, format("@%s.iam.gserviceaccount.com", var.gcp_project_id ))}.sh"

  lifecycle {
    ignore_changes = all
  }
  depends_on = [
    module.gcp-workload-identity-federation, module.azure-application, module.azure-service-principal,
    module.gcp-service-account
  ]
}

# copy generated script to the created Azure VM
resource "null_resource" "copy_scripts_to_fetch_access_token" {
  for_each = toset(module.gcp-service-account.service_accounts_emails)

  connection {
    type        = "ssh"
    user        = var.azure_vm_admin_user_name
    private_key = file(module.azure-configured-resources-with-vm.vm_ssh_privet_key_name)
    host        = module.azure-configured-resources-with-vm.vm_public_ip
  }

  provisioner "file" {
    source      = "${path.module}/scripts/fetching-access-token-${trimsuffix(each.value, format("@%s.iam.gserviceaccount.com", var.gcp_project_id ))}.sh"
    destination = "/home/adminuser/fetching-access-token-${trimsuffix(each.value, format("@%s.iam.gserviceaccount.com", var.gcp_project_id ))}.sh"
  }
  depends_on = [module.azure-configured-resources-with-vm, local_file.generate_fetching_access_token_scripts]
}