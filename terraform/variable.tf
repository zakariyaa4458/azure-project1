variable "tenant_id" {
  description = "The tenant ID for the Azure subscription."
  type        = string
}

variable "key_vault_secret_id" {
    description = "key vault secret https uri"
    type        =  string 
}