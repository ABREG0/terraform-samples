
variable "name" {
  type        = string
  description = "(required) describe your variable"
  default     = ""
}
variable "resource_group_name" {
  type        = string
  description = "(required) describe your variable"
  default     = ""
}
variable "location" {
  type        = string
  description = "(required) describe your variable"
  default     = ""
}
variable "log_analytics_workspace_id" {
  type        = string
  description = "(optional) describe your variable"
  default     = null
}

variable "tags" {
  type        = map(any)
  description = "(required) describe your variable"
  default     = {}
}

resource "azurerm_network_security_group" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      # tags, 
      tags,
    ]
  }
}

# module "diag" {
#   source                     = "../../diag"
#   name                       = "${azurerm_network_security_group.this.name}-diag-logging"
#   log_analytics_workspace_id = var.log_analytics_workspace_id
#   resource_id                = azurerm_network_security_group.this.id
# }
output "id" {
  value = azurerm_network_security_group.this.id
}
output "name" {
  value = azurerm_network_security_group.this.name
}
output "location" {
  value = azurerm_network_security_group.this.location
}
