resource "azurerm_log_analytics_workspace" "azure_log_analytics_workspace" {
  name                = "azure-log-analytics-workspace"
  location            = var.rg_azure_project1_location
  resource_group_name = var.rg_azure_project1_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}