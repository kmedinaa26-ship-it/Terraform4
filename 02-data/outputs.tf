output "postgres_server_id" {
  value = azurerm_postgresql_flexible_server.main.id
}

output "postgres_server_name" {
  value = azurerm_postgresql_flexible_server.main.name
}

output "postgres_fqdn" {
  value = azurerm_postgresql_flexible_server.main.fqdn
}

output "storage_account_id" {
  value = azurerm_storage_account.main.id
}

output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "blob_endpoint" {
  value = azurerm_storage_account.main.primary_blob_endpoint
}

output "blob_container_name" {
  value = azurerm_storage_container.datos.name
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
