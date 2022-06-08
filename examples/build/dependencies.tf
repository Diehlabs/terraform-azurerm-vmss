# Generate an ssh key and certs
# https://registry.terraform.io/providers/hashicorp/tls/latest/docs

#generate an ssh key
resource "tls_private_key" "vmss_ssh" {
  count     = var.create_public_key == true ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = "2048"
}

data "azurerm_resource_group" "vnet_rg" {
  name = var.network_resource_group_name
}

data "azurerm_virtual_network" "vmss_vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.vnet_rg.name
}

data "azurerm_subnet" "vmss_subnet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vmss_vnet.name
  resource_group_name  = data.azurerm_resource_group.vnet_rg.name
}

# In progress. 
# resource "azurerm_user_assigned_identity" "generated" {
#   # count               = var.create_identity == true ? 1 : 0
#   location            = var.tags.region
#   name                = local.identity_name
#   resource_group_name = local.resource_group_name
#   tags                = var.tags
# }
