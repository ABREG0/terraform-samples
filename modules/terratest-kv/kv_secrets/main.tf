
# terraform {
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "=2.99.0"
#     }
#   }
# }

# provider "azurerm" {
#   features {}

# }

variable "secrets" {
    type = map(object({
        name         = string
        value        = string
        key_vault_id = string
        not_before_date = string  # (Optional) Key not usable before the provided UTC datetime (Y-m-d'T'H:M:S'Z')
        expiration_date = string  # (Optional) Expiration UTC datetime (Y-m-d'T'H:M:S'Z').
        tags            = map(string)
     }))
}

resource "azurerm_key_vault_secret" "this" {
  for_each = var.secrets
  name         = each.value.name
  value        = each.value.value
  key_vault_id = each.value.key_vault_id

  not_before_date = each.value.not_before_date  # (Optional) Key not usable before the provided UTC datetime (Y-m-d'T'H:M:S'Z')
  expiration_date = each.value.expiration_date  # (Optional) Expiration UTC datetime (Y-m-d'T'H:M:S'Z').
  tags = each.value.tags
}

# output "id" {
#   value = azurerm_key_vault_secret.this.id
# }
# output "name" {
#   value = azurerm_key_vault_secret.this.name
# }
# output "version" {
#   value = azurerm_key_vault_secret.this.version
# }
# output "keyVault" {
#   value = azurerm_key_vault_secret.this
# }
