resource "azurerm_log_analytics_workspace" "azure_log_analytics_workspace" {
  name                = "azure-log-analytics-workspace"
  location            = var.rg_azure_project1_location
  resource_group_name = var.rg_azure_project1_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_monitor_diagnostic_setting" "app_gateway_diagnostics" {
  name                       = "app-gateway-diagnostics"
  target_resource_id         = var.azure_app_gateway_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.azure_log_analytics_workspace.id

  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }
enabled_metric {
  category = "AllMetrics"
}

}