

variable "name" {
  type        = string
  description = "(required) app name"
  default     = null
}

variable "resource_group_name" {
  type        = string
  description = "(required) resource group name"
  default     = null
}

variable "location" {
  type        = string
  description = "(required) location / region"
  default     = null
}

variable "subnet_id" {
  type        = string
  description = "(required) subnet id"
  default     = null
}

variable "private_dns_zone_group" {
  # type = map(string)
  description = "(optional) private dns group ids"
  default = {
    name                 = ""
    private_dns_zone_ids = []
  }
}

variable "private_service_connection" {
  # type = map(string)
  description = "(optional) private service connection"
  default = {
    name                           = ""
    private_connection_resource_id = ""
    is_manual_connection           = false
    subresource_names              = ["", ""]
  }
}

variable "tags" {
  type        = map(any)
  description = "(required) tags"
  default     = {}
}

resource "azurerm_private_endpoint" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.subnet_id
  tags                = var.tags

  # creates dns record
  private_dns_zone_group {
    name                 = var.private_dns_zone_group.name
    private_dns_zone_ids = var.private_dns_zone_group.private_dns_zone_ids
  }

  private_service_connection {
    name                           = var.private_service_connection.name
    private_connection_resource_id = var.private_service_connection.private_connection_resource_id
    is_manual_connection           = var.private_service_connection.is_manual_connection
    subresource_names              = var.private_service_connection.subresource_names
  }

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
  value = azurerm_private_endpoint.this.id
}
output "name" {
  value = azurerm_private_endpoint.this.name
}
output "location" {
  value = azurerm_private_endpoint.this.location
}
output "privateEndpoint" {
  value = azurerm_private_endpoint.this
}
