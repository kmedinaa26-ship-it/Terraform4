variable "subscription_id" {
  description = "ID de la suscripcion Azure for Students."
  type        = string
}

variable "bastion_sku" {
  description = "Basic es suficiente para SSH desde el portal (Portal TLS 443)."
  type        = string
  default     = "Basic"
}

variable "tags" {
  type = map(string)
  default = {
    environment = "prod"
    workload    = "landing-zone"
    managed_by  = "terraform"
  }
}
