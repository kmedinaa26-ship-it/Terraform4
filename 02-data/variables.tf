variable "subscription_id" {
  description = "ID de la suscripcion Azure for Students."
  type        = string
}

variable "postgres_version" {
  type    = string
  default = "16"
}

variable "postgres_sku" {
  description = "SKU Burstable segun el diagrama."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgres_storage_mb" {
  type    = number
  default = 32768
}

variable "postgres_private_ip" {
  description = "IP estatica del Private Endpoint de PostgreSQL (snet-db)."
  type        = string
  default     = "10.0.2.4"
}

variable "blob_private_ip" {
  description = "IP estatica del Private Endpoint de Blob (snet-endpoints)."
  type        = string
  default     = "10.0.4.4"
}

variable "blob_container_name" {
  type    = string
  default = "datos"
}

variable "tags" {
  type = map(string)
  default = {
    environment = "prod"
    workload    = "landing-zone"
    managed_by  = "terraform"
  }
}
