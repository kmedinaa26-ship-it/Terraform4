output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "location" {
  value = azurerm_resource_group.main.location
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "vnet_name" {
  value = azurerm_virtual_network.main.name
}

output "subnet_ids" {
  value = {
    app       = azurerm_subnet.app.id
    db        = azurerm_subnet.db.id
    vm        = azurerm_subnet.vm.id
    endpoints = azurerm_subnet.endpoints.id
    bastion   = azurerm_subnet.bastion.id
  }
}

output "private_dns_zone_ids" {
  value = {
    postgres = azurerm_private_dns_zone.postgres.id
    blob     = azurerm_private_dns_zone.blob.id
  }
}
