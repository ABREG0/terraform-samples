
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

variable "key_vault_id" {
  type        = string
  description = "(required) describe your variable"
  default     = null
}
variable "object_id" {
  type        = string
  description = "(required) describe your variable"
  default     = null 
}
variable "key_permissions" {
  type        = string
  description = "(required) describe your variable"
  default     = []
}
variable "secret_permissions" {
  type        = string
  description = "(required) describe your variable"
  default     = []
}
variable "storage_permissions" {
  type        = string
  description = "(required) describe your variable"
  default     = []
}

data "azurerm_client_config" "this" {}

data "azurerm_synapse_workspace" "this" {
  name                = "oeasynapname"
  resource_group_name = "ted-ml-dev-centralus"
}

resource "azurerm_key_vault_access_policy" "this" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.this.tenant_id
  object_id    = var.object_id

  key_permissions = var.key_permissions
  secret_permissions = var.secret_permissions
  storage_permissions = var.storage_permissions

}