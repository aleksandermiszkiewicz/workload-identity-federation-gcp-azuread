data "azuread_client_config" "client" {}

data "azurerm_resource_group" "resource_group" {
  name = var.resource_group
}

# azure ad application registration
resource "azuread_application" "application" {
  display_name            = var.application_name
  owners                  = [data.azuread_client_config.client.object_id]
  sign_in_audience        = var.application_sign_in_audience
  group_membership_claims = ["SecurityGroup"]
}

# registering Application ID URI
resource "null_resource" "register_application_id_uri" {
  provisioner "local-exec" {
    command = "az ad app update --id ${azuread_application.application.object_id} --identifier-uris api://${azuread_application.application.application_id}"
  }
}