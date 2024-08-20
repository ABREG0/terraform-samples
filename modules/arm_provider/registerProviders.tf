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

variable "ms_providers" {
  type        = set(string)
  description = "(optional) describe your variable"
  default     = ["Microsoft.Sql", "Microsoft.ManagedIdentity", "Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.DataShare", "Microsoft.Synapse", "Microsoft.Synapse"]
}

resource "azurerm_resource_provider_registration" "microsoft_provider" {
  for_each = toset(var.ms_providers)
  name     = each.value
}