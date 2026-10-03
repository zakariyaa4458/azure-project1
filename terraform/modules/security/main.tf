resource "azurerm_subnet_network_security_group_association" "azure_subnet_public_nsg_association" {
  subnet_id                 = var.app_gateway_subnet_id
  network_security_group_id = azurerm_network_security_group.azure_public_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "azure_subnet_private_nsg_association" {
  subnet_id                 = var.container_subnet_id
  network_security_group_id = azurerm_network_security_group.azure_private_nsg.id
}

resource "azurerm_network_security_group" "azure_public_nsg" {
  name                = "azure-public-nsg"
  location            = var.rg_azure_project1_location
  resource_group_name = var.rg_azure_project1_name



  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_security_group" "azure_private_nsg" {
  name                = "azure-private-nsg"
  location            = var.rg_azure_project1_location
  resource_group_name = var.rg_azure_project1_name



  tags = {
    environment = "Production"
  }
}


resource "azurerm_network_security_rule" "azure_public_nsg_rule" {
  name                        = "azure-public-nsg-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = var.rg_azure_project1_name
  network_security_group_name = azurerm_network_security_group.azure_public_nsg.name
}


resource "azurerm_network_security_rule" "azure_public_nsg_rule_2" {
# checkov:skip=CKV_AZURE_160:Port 80 is used only for HTTP-to-HTTPS redirection at Application Gateway
  name                        = "azure-public-nsg-rule-2"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = var.rg_azure_project1_name
  network_security_group_name = azurerm_network_security_group.azure_public_nsg.name
}


resource "azurerm_network_security_rule" "azure_private_nsg_rule" {
  name                        = "azure-private-nsg-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3000"
  source_address_prefix       =  var.container_subnet_address_prefix[0]
  destination_address_prefix  = "*"
  resource_group_name         = var.rg_azure_project1_name
  network_security_group_name = azurerm_network_security_group.azure_private_nsg.name
}
