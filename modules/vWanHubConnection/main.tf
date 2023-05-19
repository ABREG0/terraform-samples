
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

# variable "traffic_settings" {
#   type = object({
#     is_gateway_installed = optional(bool, false)
#     config = object({
#       hub_to_vitual_network_traffic_allowed             = optional(bool, true)
#       vitual_network_to_hub_gateways_traffic_allowed     = optional(bool, true)
#     })
#   })
# }

resource "azurerm_virtual_hub_connection" "this" {
  name = var.name # "${data.azurerm_virtual_network.source.name}-with-${data.azurerm_virtual_hub.vhub.name}"
  virtual_hub_id            = var.virtual_hub_id # data.azurerm_virtual_hub.vhub.id
  remote_virtual_network_id = var.remote_virtual_network_id #data.azurerm_virtual_network.source.id
  # hub_to_vitual_network_traffic_allowed = var.hub_to_vitual_network_traffic_allowed
  # vitual_network_to_hub_gateways_traffic_allowed = var.vitual_network_to_hub_gateways_traffic_allowed
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