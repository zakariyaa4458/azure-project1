variable "azure_log_analytics_workspace_id" {
  description = "The ID of the Azure Log Analytics Workspace."
  type        = string
}

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

variable "container_subnet_id" {
  description = "The ID of the container subnet."
  type        = string
}

variable "container_registry_login_server" {
  description = "The login server of the Azure Container Registry."
  type        = string
}