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