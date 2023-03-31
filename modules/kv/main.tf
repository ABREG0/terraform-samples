
variable "name" {
  type        = string
  description = "(required) describe your variable"
  default     = "ted-kv-dev-centralus"
}
variable "resource_group_name" {
  type        = string
  description = "(required) describe your variable"
  default     = "ted-ml-dev-centralus"
}
variable "location" {
  type        = string
  description = "(required) describe your variable"
  default     = "centralus"
}

variable "log_analytics_workspace_id" {
  description = "Required: workspace to send logs"
  default     = null
}
variable "enable_rbac_authorization" {
  type        = bool
  description = "(required) describe your variable"
  default     = true
}
variable "purge_protection_enabled" {
  type        = bool
  description = "(required) describe your variable"
  default     = false
}

variable "enabled_for_deployment" {
  type        = bool
  description = "(required) describe your variable"
  default     = true
}
variable "enabled_for_template_deployment" {
  type        = bool
  description = "(required) describe your variable"
  default     = true
}
variable "enabled_for_disk_encryption" {
  type        = bool
  description = "(required) describe your variable"
  default     = true
}

variable "sku" {
  type        = string
  description = "(required) describe your variable"
  default     = "standard"
}
variable "network_default_action" {
  type        = string
  description = "(optional) describe your variable"
  default     = "Deny"
}
variable "bypass" {
  type        = string
  description = "(required) describe your variable"
  default     = "AzureServices"
}
variable "ip_rules" {
  type        = list(string)
  description = "(required) describe your variable"
  default     = [] # ["43.0.0.0/24","54.0.0.0/24"]
}
variable "allowed_subnets" {
  type        = list(string)
  description = "(required) describe your variable"
  default     = [] # ["id1","id2"]
}

variable "tags" {
  type        = map(any)
  description = "(required) describe your variable"
  default = {
    environment = "dev"
    owner       = "IT"
  }

}

data "azurerm_client_config" "this" {}

resource "azurerm_key_vault" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  tenant_id                       = data.azurerm_client_config.this.tenant_id
  soft_delete_retention_days      = 30
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.purge_protection_enabled
  sku_name                        = var.sku
  tags                            = var.tags
  network_acls {
    default_action             = var.network_default_action
    bypass                     = var.bypass
    ip_rules                   = var.ip_rules
    virtual_network_subnet_ids = var.allowed_subnets
  }

}

# resource "azurerm_monitor_diagnostic_setting" "this" {
#   name               = "${var.name}-logging"
#   target_resource_id = azurerm_key_vault.this.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   # storage_account_id = data.azurerm_storage_account.this.id

#   enabled_log {
#     category = "Logs"

#     retention_policy {
#       enabled = false
#     }
#   }

#   metric {
#     category = "Metrics"

#     retention_policy {
#       enabled = false
#     }
#   }
# }

output "id" {
  value = azurerm_key_vault.this.id
}
output "name" {
  value = azurerm_key_vault.this.name
}
output "location" {
  value = azurerm_key_vault.this.location
}
output "keyVault" {
  value = azurerm_key_vault.this
}

  