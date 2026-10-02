terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstateflaskapp"
    container_name       = "tfstate"
    key                  = "flaskapp.tfstate"
  }
}
