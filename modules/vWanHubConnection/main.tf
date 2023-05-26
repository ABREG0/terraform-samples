
variable "name" {
  type        = string
  description = "(required) describe your variable"
  default     = "vwan-dev-westus3"
}
variable "virtual_hub_id" {
  type        = string
  description = "(required) describe your variable"
}
variable "remote_virtual_network_id" {
  type        = string
  description = "(required) describe your variable"
  default     = "westus3"
}

variable "routing" {
  type = map(object({
    associated_route_table_id  = optional(string)
    propagated_route_table = optional(list(object({
      labels              = list(string)
      route_table_ids              = list(string)
      }))
    )
    static_vnet_route = optional(list(object({
      name = optional(string)
      address_prefixes              = list(string)
      next_hop_ip_address              = list(string)
      }))
    )
  }))
}

resource "azurerm_virtual_hub_connection" "this" {
  name                      = var.name                      # "${data.azurerm_virtual_network.source.name}-with-${data.azurerm_virtual_hub.vhub.name}"
  virtual_hub_id            = var.virtual_hub_id            # data.azurerm_virtual_hub.vhub.id
  remote_virtual_network_id = var.remote_virtual_network_id #data.azurerm_virtual_network.source.id
  internet_security_enabled = false                         # var.internet_security_enabled

  routing {
    associated_route_table_id = null # (Optional) The ID of the route table associated with this Virtual Hub connection.

    propagated_route_table {
      labels          = [] #(Optional) The list of labels to assign to this route table.
      route_table_ids = []
    }
    static_vnet_route {
      name                = null # (Optional) The name which should be used for this Static Route.
      address_prefixes    = []   # (Optional) A list of CIDR Ranges which should be used as Address Prefixes.
      next_hop_ip_address = null
    }
  }
}

output "id" {
  value = azurerm_virtual_hub_connection.this.id
}
output "name" {
  value = azurerm_virtual_hub_connection.this.name
}


/*
variable "source_vnet" {
  description = "vnet map name and rg"
  type        = map(string)
  default = {
    "name"                = "vn-mtm-prod-wus2-01"
    "resource_group_name" = "vwan-rg"
  }
}

variable "vhub" {
  description = "vhub map name and rg"
  type        = map(string)
  default = {
    "name"                = "vwan-rg"
    "resource_group_name" = "vwan-rg"
  }
}

data "azurerm_virtual_network" "source" {
  name                = var.source_vnet.name
  resource_group_name = var.source_vnet.resource_group_name
}

data "azurerm_virtual_hub" "vhub" {
  name                = var.vhub.name
  resource_group_name = var.vhub.resource_group_name
}



variable "vhub_connection" {
  type = map(string)
  default = {
    "name" = "vnetName"
  }
}

variable "vwan" {
  type = map(string)
}

data "azurerm_virtual_wan" "vwan" {
  name                = var.vwan.name
  resource_group_name = var.vwan.resource_group_name
 }
*/