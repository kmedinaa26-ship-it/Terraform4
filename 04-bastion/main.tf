###############################################################################
# Proyecto 04-bastion
# Azure Bastion en AzureBastionSubnet para administrar la VM por SSH privado.
###############################################################################

locals {
  rg       = data.terraform_remote_state.network.outputs.resource_group_name
  location = data.terraform_remote_state.network.outputs.location
  subnets  = data.terraform_remote_state.network.outputs.subnet_ids
}

resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion"
  location            = local.location
  resource_group_name = local.rg
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "main" {
  name                = "bas-lz-prod"
  location            = local.location
  resource_group_name = local.rg
  sku                 = var.bastion_sku
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = local.subnets.bastion
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}
