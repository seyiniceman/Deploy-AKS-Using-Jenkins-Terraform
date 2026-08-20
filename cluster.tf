############################################
# 1. Terraform & Azure Provider
############################################
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

############################################
# 2. Variables
############################################
variable "resource_group_name" {
  type    = string
  default = "DevLab"
}

variable "location" {
  type    = string
  default = "Sweden Central"
}

variable "cluster_name" {
  type    = string
  default = "myapp-aks-cluster"
}

############################################
# 3. Resource Group
############################################
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = "development"
    application = "myapp"
  }
}

############################################
# 4. AKS Cluster
############################################
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "myapp"


  default_node_pool {
    name           = "dev"
    vm_size        = "Standard_B2s_v2"
    node_count     = 1
    vnet_subnet_id = azurerm_subnet.aks.id
  }
  node_provisioning_profile {
    mode = "Manual"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.1.0.0/16"
    dns_service_ip = "10.1.0.10"
  }

  tags = {
    environment = "development"
    application = "myapp"
  }
}

############################################
# 5. Outputs
############################################
output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "cluster_fqdn" {
  value = azurerm_kubernetes_cluster.aks.fqdn
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}