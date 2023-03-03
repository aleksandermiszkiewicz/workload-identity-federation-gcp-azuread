data "azuread_client_config" "client" {}

data "azurerm_resource_group" "resource_group" {
  name = var.resource_group
}

# azure ad service principal assigning
resource "azuread_service_principal" "service_principal" {
  application_id               = var.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.client.object_id]
  use_existing                 = true
}

# assignment a Reader role to the created service principal to read resource group resources
resource "azurerm_role_assignment" "reader_role_to_rg" {
  principal_id         = azuread_service_principal.service_principal.object_id
  scope                = data.azurerm_resource_group.resource_group.id
  role_definition_name = "Reader"
}

# creating secret for service principal
resource "azuread_service_principal_password" "service_principal_secret" {
  end_date             = "2299-12-30T23:00:00Z"
  service_principal_id = azuread_service_principal.service_principal.id
}
