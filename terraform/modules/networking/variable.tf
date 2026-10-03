variable "container_app_fqdn" {
  description = "The fully qualified domain name (FQDN) of the container app."
  type        = string
}

variable "app_gateway_kv_id"{
    description = "key vault id for app gateway"
    type = string
}

variable "key_vault_secret_id" {
  type = string
}

variable "application_gateway_identity_id" {
  type = string
}