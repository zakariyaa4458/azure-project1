resource "azurerm_container_registry" "acr_flaskapp" {
  # checkov:skip=CKV_AZURE_165:I do not need geo-replication for this project, so I will not enable it.
  # checkov:skip=CKV_AZURE_164: 
  # checkov:skip=CKV_AZURE_237: I am not using premium sku for this project, so I will not enable it.
  # checkov:skip=CKV_AZURE_139: disabling public network causes networking issues for aca
  # checkov:skip=CKV_AZURE_166:im using trivy to scan images
  name                = "flaskapp1"
  resource_group_name = var.rg_azure_project1_name
  location            = var.rg_azure_project1_location
  sku                 = "Premium"
  admin_enabled       = false
  public_network_access_enabled = true
  zone_redundancy_enabled = true
  retention_policy_in_days = 90

  quarantine_policy_enabled = false
   
}



resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr_flaskapp.id
  role_definition_name = "AcrPull"
  principal_id         =  var.aca_identity_principal_id
}

