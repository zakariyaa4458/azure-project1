output "vnet_id" {
  value = azurerm_virtual_network.azure_vnet.id
}

output "rg_azure_project1_name" {
  value = azurerm_resource_group.rg-azure-project1.name
}

output "rg_azure_project1_location" {
  value = azurerm_resource_group.rg-azure-project1.location
}

output "container_subnet_id" {
  value = azurerm_subnet.container_subnet.id
}

output "app_gateway_subnet_id" {
  value = azurerm_subnet.app_gateway_subnet.id
}

output "container_subnet_address_prefix" {
  value = azurerm_subnet.container_subnet.address_prefixes
}