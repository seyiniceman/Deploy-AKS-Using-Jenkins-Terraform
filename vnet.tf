############################################
# Network Variables
############################################

variable "vnet_cidr_block" {
  type = string
}

variable "aks_subnet_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

############################################
# Virtual Network
############################################

resource "azurerm_virtual_network" "main" {
  name                = "myapp-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  address_space = [
    var.vnet_cidr_block
  ]

  tags = {
    environment = "development"
    application = "myapp"
  }
}

############################################
# AKS Subnet
############################################

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = [
    var.aks_subnet_cidr
  ]
}

############################################
# Public Subnet
############################################

resource "azurerm_subnet" "public" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = [
    var.public_subnet_cidr
  ]
}