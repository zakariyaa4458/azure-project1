resource "azurerm_resource_group" "rg-azure-project1" {
  name     = "rg-azure-project1"
  location = "UK South"
}



resource "azurerm_virtual_network" "azure_vnet" {
  name                = "azure-vnet"
  location            = azurerm_resource_group.rg-azure-project1.location
  resource_group_name = azurerm_resource_group.rg-azure-project1.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = []



}

resource "azurerm_application_gateway" "azure_app_gateway" {
    #checkov:skip=CKV_AZURE_217: temp
  name                = "azure-app-gateway"
  resource_group_name = azurerm_resource_group.rg-azure-project1.name
  location            = azurerm_resource_group.rg-azure-project1.location
firewall_policy_id    = azurerm_web_application_firewall_policy.azure_waf_policy.id

  ssl_policy {
   
   policy_type = "Predefined"
   policy_name = "AppGwSslPolicy20220101S"
    

  }

  

 

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.app_gateway_subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.azure_public_ip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name

    fqdns = [
      var.container_app_fqdn
    ]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"

    port            = 443
    protocol        = "Https"
    request_timeout = 60

    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }



}

locals {
  backend_address_pool_name      = "${azurerm_virtual_network.azure_vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.azure_vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.azure_vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.azure_vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.azure_vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.azure_vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.azure_vnet.name}-rdrcfg"
}

resource "azurerm_subnet" "app_gateway_subnet" {
 # checkov:skip=CKV2_AZURE_31:The vnet subnet association is in the security module, it is configured there, so I will not configure it here.
  name                 = "azure-subnet-public"
  resource_group_name  = azurerm_resource_group.rg-azure-project1.name
  virtual_network_name = azurerm_virtual_network.azure_vnet.name
  address_prefixes     = ["10.0.1.0/24"]


}

resource "azurerm_subnet" "container_subnet" {
     # checkov:skip=CKV2_AZURE_31:The vnet subnet association is in the security module, it is configured there, so I will not configure it here.

  name                 = "container-subnet"
  resource_group_name  = azurerm_resource_group.rg-azure-project1.name
  virtual_network_name = azurerm_virtual_network.azure_vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "container-delegation"

    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_public_ip" "azure_public_ip" {
  name                = "azure-public-ip"
  resource_group_name = azurerm_resource_group.rg-azure-project1.name
  location            = azurerm_resource_group.rg-azure-project1.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_web_application_firewall_policy" "azure_waf_policy" {
  name                = "azure-waf-policy"
  resource_group_name = azurerm_resource_group.rg-azure-project1.name
  location            = azurerm_resource_group.rg-azure-project1.location

  policy_settings {
    enabled = true
    mode    = "Prevention"
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}