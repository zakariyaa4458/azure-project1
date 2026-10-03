module "app" {
  source                           = "./modules/app"
  rg_azure_project1_name           = module.networking.rg_azure_project1_name
  rg_azure_project1_location       = module.networking.rg_azure_project1_location
  azure_log_analytics_workspace_id = module.logs.azure_log_analytics_workspace_id
  vnet_id                          = module.networking.vnet_id
  container_subnet_id              = module.networking.container_subnet_id
  container_registry_login_server  = module.acr.container_registry_login_server
  acr_pull_role_assignment         = module.acr.acr_pull_role_assignment.id


  # depends_on = [
  #  module.acr
  #]


}

module "networking" {
  source             = "./modules/networking"
  container_app_fqdn = module.app.container_app_fqdn
  app_gateway_kv_id = module.security.app_gateway_kv_id
  key_vault_secret_id = var.key_vault_secret_id
  application_gateway_identity_id = module.app.application_gateway_identity_id.id
  


}

module "security" {
  source                          = "./modules/security"
  vnet_id                         = module.networking.vnet_id
  rg_azure_project1_name          = module.networking.rg_azure_project1_name
  rg_azure_project1_location      = module.networking.rg_azure_project1_location
  container_subnet_id             = module.networking.container_subnet_id
  app_gateway_subnet_id           = module.networking.app_gateway_subnet_id
  container_subnet_address_prefix = module.networking.container_subnet_address_prefix
  tenant_id                       = var.tenant_id

}

module "logs" {
  source                     = "./modules/logs"
  rg_azure_project1_name     = module.networking.rg_azure_project1_name
  rg_azure_project1_location = module.networking.rg_azure_project1_location
  vnet_id                    = module.networking.vnet_id
}

module "acr" {
  source                     = "./modules/acr"
  rg_azure_project1_name     = module.networking.rg_azure_project1_name
  rg_azure_project1_location = module.networking.rg_azure_project1_location
  vnet_id                    = module.networking.vnet_id
  container_app_principal_id = module.app.container_app_principal_id
  aca_identity_id            = module.app.aca_identity_id
  aca_identity_principal_id  = module.app.aca_identity_principal_id
  app_gateway_kv_id          = module.security.app_gateway_kv_id


}

import {
  id = "/subscriptions/2930bc1b-5d66-43da-9d15-54c0b439b62c/resourceGroups/rg-azure-project1"
  to = module.networking.azurerm_resource_group.rg-azure-project1
}

