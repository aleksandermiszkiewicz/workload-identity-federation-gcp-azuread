data "azurerm_resource_group" "resource_group" {
  name = var.resource_group
}

resource "azurerm_user_assigned_identity" "managed_identity" {
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  name                = var.managed_identity_name
}

# assignment a Reader role to the created managed identity to read resource group resources
resource "azurerm_role_assignment" "reader_role_to_rg" {
  principal_id         = azurerm_user_assigned_identity.managed_identity.principal_id
  scope                = data.azurerm_resource_group.resource_group.id
  role_definition_name = "Reader"
}