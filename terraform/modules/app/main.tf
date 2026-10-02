

resource "azurerm_container_app" "azure_flask_app" {
  name                         = "azure-flask-app"
  container_app_environment_id = azurerm_container_app_environment.azure_flask_container_app_environment.id
  resource_group_name          = var.rg_azure_project1_name
  revision_mode                = "Single"


  identity {
    type = "SystemAssigned"
  }

  registry {
    server   = var.container_registry_login_server
    identity = "System"
  }


  ingress {
    external_enabled = true
    target_port      = 3000

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }


  template {

    min_replicas = 1
    max_replicas = 3

    http_scale_rule {
      name                = "http-scale-rule"
      concurrent_requests = "50"

    }
    container {
      name   = "examplecontainerapp"
      image  = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

}

resource "azurerm_container_app_environment" "azure_flask_container_app_environment" {
  name                       = "Example-Environment"
  location                   = var.rg_azure_project1_location
  resource_group_name        = var.rg_azure_project1_name
  log_analytics_workspace_id = var.azure_log_analytics_workspace_id

  infrastructure_subnet_id = var.container_subnet_id
}