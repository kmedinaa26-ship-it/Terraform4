###############################################################################
# Proyecto 03-compute
# App Service (VNet Integration) + VM worker, ambos con System-Assigned
# Managed Identity (MI), RBAC sobre Blob y administrador Entra en PostgreSQL.
###############################################################################

locals {
  rg       = data.terraform_remote_state.network.outputs.resource_group_name
  location = data.terraform_remote_state.network.outputs.location
  subnets  = data.terraform_remote_state.network.outputs.subnet_ids

  pg_name      = data.terraform_remote_state.data.outputs.postgres_server_name
  pg_fqdn      = data.terraform_remote_state.data.outputs.postgres_fqdn
  storage_id   = data.terraform_remote_state.data.outputs.storage_account_id
  storage_name = data.terraform_remote_state.data.outputs.storage_account_name
  blob_url     = data.terraform_remote_state.data.outputs.blob_endpoint
  tenant_id    = data.terraform_remote_state.data.outputs.tenant_id
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# --- App Service Linux B1 con VNet Integration -----------------------------------------

resource "azurerm_service_plan" "app" {
  name                = "asp-lz-prod"
  resource_group_name = local.rg
  location            = local.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  tags                = var.tags
}

resource "azurerm_linux_web_app" "app" {
  name                = "app-lz-prod-${random_string.suffix.result}"
  resource_group_name = local.rg
  location            = local.location
  service_plan_id     = azurerm_service_plan.app.id
  https_only          = true

  # VNet Integration: trafico saliente por snet-app (delegada a Microsoft.Web/serverFarms)
  virtual_network_subnet_id = local.subnets.app

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on              = true
    vnet_route_all_enabled = true # todo el trafico saliente pasa por la VNet (Private DNS)
    minimum_tls_version    = "1.2"
    ftps_state             = "Disabled"

    application_stack {
      node_version = var.app_node_version
    }
  }

  app_settings = {
    PGHOST                    = local.pg_fqdn
    PGPORT                    = "5432"
    PGDATABASE                = var.database_name
    PGSSLMODE                 = "require"
    PGUSER                    = "app-lz-prod-${random_string.suffix.result}" # = nombre de la MI
    AZURE_STORAGE_ACCOUNT_URL = trimsuffix(local.blob_url, "/")
    WEBSITE_DNS_SERVER        = "168.63.129.16"
  }

  tags = var.tags
}

# --- VM Linux worker (B2ats_v2) ---------------------------------------------------------

resource "azurerm_network_interface" "vm" {
  name                = "nic-vm-worker"
  location            = local.location
  resource_group_name = local.rg
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.subnets.vm
    private_ip_address_allocation = "Dynamic"
    # Sin IP publica: la administracion se hace por Azure Bastion
  }
}

resource "azurerm_linux_virtual_machine" "worker" {
  name                = "vm-worker"
  resource_group_name = local.rg
  location            = local.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username

  network_interface_ids = [azurerm_network_interface.vm.id]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = var.vm_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  # B2ats_v2 solo soporta generacion 2
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# --- RBAC: acceso a Blob con Managed Identity (flechas 3 y 5 del diagrama) --------------

resource "azurerm_role_assignment" "app_blob" {
  scope                = local.storage_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_web_app.app.identity[0].principal_id
}

resource "azurerm_role_assignment" "vm_blob" {
  scope                = local.storage_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_virtual_machine.worker.identity[0].principal_id
}

# --- PostgreSQL: administradores Entra ID = Managed Identities (flechas 2 y 4) ----------

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "app" {
  server_name         = local.pg_name
  resource_group_name = local.rg
  tenant_id           = local.tenant_id
  object_id           = azurerm_linux_web_app.app.identity[0].principal_id
  principal_name      = azurerm_linux_web_app.app.name
  principal_type      = "ServicePrincipal"
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "vm" {
  server_name         = local.pg_name
  resource_group_name = local.rg
  tenant_id           = local.tenant_id
  object_id           = azurerm_linux_virtual_machine.worker.identity[0].principal_id
  principal_name      = azurerm_linux_virtual_machine.worker.name
  principal_type      = "ServicePrincipal"

  # Azure procesa un administrador Entra a la vez
  depends_on = [azurerm_postgresql_flexible_server_active_directory_administrator.app]
}
