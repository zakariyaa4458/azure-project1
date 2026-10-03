variable "vnet_id" {
  description = "The ID of the virtual network to which the subnet belongs."
  type        = string
  
}

variable "rg_azure_project1_name" {
  description = "The name of the resource group where the virtual network is located."
  type        = string
}

variable "rg_azure_project1_location" {
  description = "The location of the resource group where the virtual network is located."
  type        = string
}

variable "container_app_principal_id" {
  description = "The principal ID of the container app."
  type        = string
}

variable "aca_identity_id" {
 description = "The ID of the user-assigned identity for the Azure Container App."
  type        = string
}

variable "aca_identity_principal_id" {
  description = "The principal ID of the user-assigned identity for the Azure Container App."
  type        = string
}

variable "app_gateway_kv_id" {
  description = "The ID of the Azure Key Vault."
  type        = string
}

variable "application_gateway_identity_principal_id" {
    description = "app gateway identity principal id"
  type = string
}