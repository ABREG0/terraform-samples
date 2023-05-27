
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

# The following block of locals are used to avoid using
# empty object types in the code.
locals {
  empty_list   = []
  empty_map    = {}
  empty_string = ""
}
# variable "routing" {
#   type = list(object({
#     associated_route_table_id  = optional(string)
#     propagated_route_table = optional(object({
#       labels               = list(string)
#       route_table_ids      = list(string)
#       })
#     )
#     static_vnet_route = optional(object({
#       name                = optional(string)
#       address_prefixes    = list(string)
#       next_hop_ip_address = list(string)
#       })
#     )
#   }))
#   default = [ {
#                 associated_route_table_id = null
#                 propagated_route_table = {
#                   labels = []
#                   route_table_ids = []
#                   }
#                 static_vnet_route = {
#                   name   = null
#                   address_prefixes = []
#                   next_hop_ip_address = []
#                   }
#                } 
#             ]
# }

resource "azurerm_virtual_hub_connection" "this" {
  name                      = var.name                      # "${data.azurerm_virtual_network.source.name}-with-${data.azurerm_virtual_hub.vhub.name}"
  virtual_hub_id            = var.virtual_hub_id            # data.azurerm_virtual_hub.vhub.id
  remote_virtual_network_id = var.remote_virtual_network_id #data.azurerm_virtual_network.source.id
  internet_security_enabled = false                         # var.internet_security_enabled
  
    # Dynamic configuration blocks
  /*
  dynamic "routing" {
    for_each = var.routing
    content {
      # Optional attributes
      associated_route_table_id = lookup(routing.value, "associated_route_table_id", null)
      dynamic "propagated_route_table" {
        for_each = lookup(routing.value, "propagated_route_table", local.empty_map)
        content {
          # Optional attributes
          labels          = lookup(propagated_route_table.value, "labels", local.empty_list)
          route_table_ids = lookup(propagated_route_table.value, "route_table_ids", local.empty_list)
        }
      }
      dynamic "static_vnet_route" {
        for_each = lookup(routing.value, "static_vnet_route", local.empty_map)
        content {
          # Optional attributes
          name                = lookup(static_vnet_route.value, "name", null)
          address_prefixes    = lookup(static_vnet_route.value, "address_prefixes", local.empty_list)
          next_hop_ip_address = lookup(static_vnet_route.value, "next_hop_ip_address", local.empty_list)
        }
      }
    }
  }
  */
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