variable "subscription_id" {
  description = "ID de la suscripcion Azure for Students."
  type        = string
}

variable "location" {
  description = "Region de Azure. Azure for Students restringe regiones; verifique cuales permite su suscripcion."
  type        = string
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos compartido por todos los proyectos."
  type        = string
  default     = "rg-lz-prod"
}

variable "vnet_name" {
  type    = string
  default = "vnet-lz-prod"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Subredes de la landing zone (segun el diagrama)."
  type = object({
    app       = string
    db        = string
    vm        = string
    endpoints = string
    bastion   = string
  })
  default = {
    app       = "10.0.1.0/24"
    db        = "10.0.2.0/24"
    vm        = "10.0.3.0/24"
    endpoints = "10.0.4.0/24"
    bastion   = "10.0.5.0/24"
  }
}

variable "tags" {
  type = map(string)
  default = {
    environment = "prod"
    workload    = "landing-zone"
    managed_by  = "terraform"
  }
}
