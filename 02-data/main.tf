###############################################################################
# Proyecto 02-data
# PostgreSQL Flexible Server y Storage Account (Blob) sin acceso publico,
# accesibles solo mediante Private Endpoint + Private DNS.
###############################################################################

locals {
  rg        = data.terraform_remote_state.network.outputs.resource_group_name
  location  = data.terraform_remote_state.network.outputs.location
  subnets   = data.terraform_remote_state.network.outputs.subnet_ids
  dns_zones = data.terraform_remote_state.network.outputs.private_dns_zone_ids
}

# Sufijo aleatorio: los nombres de storage y PostgreSQL deben ser globalmente unicos
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# --- PostgreSQL Flexible Server ----------------------------------------------------

resource "azurerm_postgresql_flexible_server" "main" {
  name                = "psql-lz-prod-${random_string.suffix.result}"
  resource_group_name = local.rg
  location            = local.location
  version             = var.postgres_version
  sku_name            = var.postgres_sku
  storage_mb          = var.postgres_storage_mb
  storage_tier        = "P4"

  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  public_network_access_enabled = false # acceso solo por Private Endpoint

  # Solo autenticacion Microsoft Entra ID (token de Managed Identity)
  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = false
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [zone]
  }
}

resource "azurerm_private_endpoint" "postgres" {
  name                = "pe-postgres"
  location            = local.location
  resource_group_name = local.rg
  subnet_id           = local.subnets.db
  tags                = var.tags

  private_service_connection {
    name                           = "psc-postgres"
    private_connection_resource_id = azurerm_postgresql_flexible_server.main.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  ip_configuration {
    name               = "ipconfig-postgres"
    private_ip_address = var.postgres_private_ip
    subresource_name   = "postgresqlServer"
    member_name        = "postgresqlServer"
  }

  private_dns_zone_group {
    name                 = "dns-postgres"
    private_dns_zone_ids = [local.dns_zones.postgres]
  }
}

# --- Storage Account (Blob, Standard LRS) --------------------------------------------

resource "azurerm_storage_account" "main" {
  name                     = "stlzprod${random_string.suffix.result}"
  resource_group_name      = local.rg
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false # acceso solo por Private Endpoint
  default_to_oauth_authentication = true

  tags = var.tags
}

# storage_account_id usa el plano de control (ARM), por lo que funciona
# aunque el acceso publico al plano de datos este deshabilitado.
resource "azurerm_storage_container" "datos" {
  name                  = var.blob_container_name
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

resource "azurerm_private_endpoint" "blob" {
  name                = "pe-blob"
  location            = local.location
  resource_group_name = local.rg
  subnet_id           = local.subnets.endpoints
  tags                = var.tags

  private_service_connection {
    name                           = "psc-blob"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  ip_configuration {
    name               = "ipconfig-blob"
    private_ip_address = var.blob_private_ip
    subresource_name   = "blob"
    member_name        = "blob"
  }

  private_dns_zone_group {
    name                 = "dns-blob"
    private_dns_zone_ids = [local.dns_zones.blob]
  }
}
