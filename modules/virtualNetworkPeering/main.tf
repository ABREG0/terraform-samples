variable "source_vnet" {
  type = map(string)
}

variable "destination_vnet" {
  type = map(string)
}


data "azurerm_virtual_network" "source" {
  name                = var.source_vnet.name
  resource_group_name = var.source_vnet.resource_group_name
}

data "azurerm_virtual_network" "destination" {
  name                = var.destination_vnet.name
  resource_group_name = var.destination_vnet.resource_group_name
}


resource "azurerm_virtual_network_peering" "destination" {
  depends_on                   = [data.azurerm_virtual_network.destination]
  name                         = "${data.azurerm_virtual_network.destination.name}_to_${data.azurerm_virtual_network.source.name}"
  virtual_network_name         = data.azurerm_virtual_network.destination.name
  resource_group_name          = data.azurerm_virtual_network.destination.resource_group_name
  remote_virtual_network_id    = data.azurerm_virtual_network.source.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "source" {
  depends_on                   = [data.azurerm_virtual_network.source]
  name                         = "${data.azurerm_virtual_network.source.name}_to_${data.azurerm_virtual_network.destination.name}"
  virtual_network_name         = data.azurerm_virtual_network.source.name
  resource_group_name          = data.azurerm_virtual_network.source.resource_group_name
  remote_virtual_network_id    = data.azurerm_virtual_network.destination.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

output "spoke_peering_id" {
  value = azurerm_virtual_network_peering.source.id
}

output "spoke_peering_name" {
  value = azurerm_virtual_network_peering.source.name
}

output "hub_peering_id" {
  value = azurerm_virtual_network_peering.destination.id
}

output "hub_peering_name" {
  value = azurerm_virtual_network_peering.destination.name
}

output "destination_name" {
  value = data.azurerm_virtual_network.destination.name
}

output "destination_id" {
  value = data.azurerm_virtual_network.destination.id
}

output "destination_rg_name" {
  value = data.azurerm_virtual_network.destination.resource_group_name
}
