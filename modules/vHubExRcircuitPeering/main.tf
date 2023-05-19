variable "peering_type" {
  type        = string
  description = "(required) describe your variable"
  default     = "AzurePrivatePeering"
}
variable "resource_group_name" {
  type        = string
  description = "(required) describe your variable"
  default     = "rg-dev-westus3"
}
variable "express_route_circuit_name" {
  type        = string
  description = "(required) describe your variable"
  default     = "westus3"
}

variable "shared_key" {
  type        = string
  description = "(required) describe your variable"
  default     = "ItsASecret"
}

variable "peer_asn" {
  type        = number
  description = "(required) describe your variable"
  default = 100
}
variable "primary_peer_address_prefix" {
  type        = string
  description = "(required) describe your variable"
  default = "192.168.1.0/30"
}
variable "secondary_peer_address_prefix" {
  type        = string
  description = "(required) describe your variable"
  default = "192.168.1.0/30"
}
variable "vlan_id" {
  type        = number
  description = "(required) describe your variable"
  default = 100
}

output "id" {
  value = azurerm_express_route_circuit_peering.this.id
}

output "peering_type" {
  value = azurerm_express_route_circuit_peering.this.peering_type
}

output "shared_key" {
  value = azurerm_express_route_circuit_peering.this.shared_key
}
output "ExR_auth_id" {
  value = azurerm_express_route_circuit_peering.this.id
}
resource "azurerm_express_route_circuit_peering" "this" {
  peering_type                  = var.peering_type
  express_route_circuit_name    = var.express_route_circuit_name
  resource_group_name           = var.resource_group_name
  shared_key                    = var.shared_key
  peer_asn                      = var.peer_asn
  primary_peer_address_prefix   = var.primary_peer_address_prefix
  secondary_peer_address_prefix = var.secondary_peer_address_prefix
  vlan_id                       = var.vlan_id
}

