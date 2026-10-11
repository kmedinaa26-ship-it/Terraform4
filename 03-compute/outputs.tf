output "app_name" {
  value = azurerm_linux_web_app.app.name
}

output "app_url" {
  value = "https://${azurerm_linux_web_app.app.default_hostname}"
}

output "app_principal_id" {
  value = azurerm_linux_web_app.app.identity[0].principal_id
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.worker.name
}

output "vm_private_ip" {
  value = azurerm_network_interface.vm.private_ip_address
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.worker.id
}

output "vm_principal_id" {
  value = azurerm_linux_virtual_machine.worker.identity[0].principal_id
}
