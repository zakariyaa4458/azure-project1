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

variable "app_gateway_subnet_id" {
  description = "The ID of the application gateway subnet."
  type        = string
}

variable "container_subnet_address_prefix" {
  description = "The address prefix of the container subnet."
  type        = list(string)
}

variable "tenant_id" {
  description = "The tenant ID for the Azure subscription."
  type        = string
}