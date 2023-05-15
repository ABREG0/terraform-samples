variable "name" {
  type        = string
  description = "(required) describe your variable"
  default     = null
}

variable "resource_group_name" {
  type        = string
  description = "(required) describe your variable"
  default     = null
}
variable "vnet_name" {
  type        = string
  description = "(required) describe your variable"
  default     = null
}
variable "vnet_id" {
  type        = string
  description = "(required) describe your variable"
  default     = null
}
variable "tags" {
  type        = map(any)
  description = "(required) describe your variable"
  default     = {}
}

resource "azurerm_private_dns_zone" "this" {
  name                = var.name
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

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  count                 = var.vnet_name != null && var.vnet_id != null ? 1 : 0
  name                  = "${var.vnet_name}-zone-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = var.vnet_id
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      # tags, 
      tags,
    ]
  }
}

output "id" {
  value = azurerm_private_dns_zone.this.id
}
output "name" {
  value = azurerm_private_dns_zone.this.name
}
output "privateDnsZone" {
  value = azurerm_private_dns_zone.this
}