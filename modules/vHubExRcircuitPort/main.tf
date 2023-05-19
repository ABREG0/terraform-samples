
variable "name" {
  type        = string
  description = "(required) describe your variable"
  default     = "vwan-dev-westus3"
}
variable "resource_group_name" {
  type        = string
  description = "(required) describe your variable"
  default     = "rg-dev-westus3"
}
variable "location" {
  type        = string
  description = "(required) describe your variable"
  default     = "westus3"
}

variable "peering_location" {
  type        = string
  description = "(required) describe your variable"
  default     = "Equinix-Seattle-SE2"
}
variable "bandwidth_in_mbps" {
  type        = number
  description = "(required) describe your variable"
  default = 10
}
variable "encapsulation" {
  type        = string
  description = "(required) describe your variable"
  default = "Dot1Q"
}
output "id" {
  value = azurerm_express_route_port.this.id
}
output "name" {
  value = azurerm_express_route_port.this.name
}

output "location" {
  value = azurerm_express_route_port.this.location
}

output "ExR_auth_id" {
  value = azurerm_express_route_port_authorization.this.id
}

output "ExR_auth_key" {
  value = azurerm_express_route_port_authorization.this.authorization_key
}
output "ExR_auth_status" {
  value = azurerm_express_route_port_authorization.this.authorization_use_status
}

resource "azurerm_express_route_port" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  peering_location    = var.peering_location 
  bandwidth_in_gbps   = 10
  encapsulation       = var.encapsulation
}
resource "azurerm_express_route_port_authorization" "this" {
  name                    = "ERCAuth-${var.name}"
  express_route_port_name = azurerm_express_route_port.this.name
  resource_group_name = var.resource_group_name
}