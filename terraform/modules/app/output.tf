output "container_app_fqdn" {
   value = azurerm_container_app.azure_flask_app.ingress[0].fqdn
}

output "container_app_principal_id" {
  value = azurerm_container_app.azure_flask_app.identity[0].principal_id
}