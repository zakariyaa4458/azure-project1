output "container_registry_login_server" {
  value = azurerm_container_registry.acr_flaskapp.login_server
}

output "acr_pull_role_assignment" {
  value = azurerm_role_assignment.acr_pull
}

#output "aca_identity_id" {
 # value = azurerm_user_assigned_identity.aca_identity.id
#}