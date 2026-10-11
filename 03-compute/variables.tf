variable "subscription_id" {
  description = "ID de la suscripcion Azure for Students."
  type        = string
}

variable "app_service_sku" {
  type    = string
  default = "B1"
}

variable "app_node_version" {
  description = "Runtime de la aplicacion (Linux)."
  type        = string
  default     = "20-lts"
}

variable "vm_size" {
  description = "Tamano de la VM worker segun el diagrama."
  type        = string
  default     = "Standard_B2ats_v2"
}

variable "vm_admin_username" {
  type    = string
  default = "azureuser"
}

variable "vm_ssh_public_key" {
  description = "Clave publica SSH (contenido de ~/.ssh/id_rsa.pub o id_ed25519.pub)."
  type        = string
}

variable "database_name" {
  type    = string
  default = "postgres"
}

variable "tags" {
  type = map(string)
  default = {
    environment = "prod"
    workload    = "landing-zone"
    managed_by  = "terraform"
  }
}
