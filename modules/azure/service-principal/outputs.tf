output "azuread_service_principal_object_id" {
  value = azuread_service_principal.service_principal.object_id
}

output "azuread_service_principal_secret" {
  value     = azuread_service_principal_password.service_principal_secret.value
  sensitive = true
}
