
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

variable "service_provider_name" {
  type        = string
  description = "(required) describe your variable"
  default     = null # "westus3"
}
variable "peering_location" {
  type        = string
  description = "(required) describe your variable"
  default = null
}
variable "bandwidth_in_mbps" {
  type        = number
  description = "(required) describe your variable"
}
variable "allow_classic_operations" {
  type = bool
}
variable "tier" {
  type        = string
  description = "(required) describe your variable"
  default     = "westus3"
}
variable "family" {
  type        = string
  description = "(required) describe your variable"
}
variable "express_route_port_id" {
  type = string
  description = "(Optional) used with bandwidth mbps"
  default = null
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(any)
  default     = {}
}

output "id" {
  value = azurerm_express_route_circuit.this.id
}
output "name" {
  value = azurerm_express_route_circuit.this.name
}

output "location" {
  value = azurerm_express_route_circuit.this.location
}
output "ExR_auth_id" {
  value = azurerm_express_route_circuit_authorization.this.id
}

output "ExR_auth_key" {
  value = azurerm_express_route_circuit_authorization.this.authorization_key
}
output "ExR_auth_status" {
  value = azurerm_express_route_circuit_authorization.this.authorization_use_status
}

resource "azurerm_express_route_circuit" "this" {
  name                  = var.name
  resource_group_name   = var.resource_group_name
  location              = var.location
  service_provider_name = var.service_provider_name
  peering_location      = var.peering_location
  bandwidth_in_mbps     = var.bandwidth_in_mbps

  # bandwidth_in_gbps     = var.bandwidth_in_gbps
  # express_route_port_id = var.express_route_port_id

  allow_classic_operations = false

  sku {
    tier   = var.tier
    family = var.family
  }

  tags = var.tags
}
resource "azurerm_express_route_circuit_authorization" "this" {
  name                       = "ERCAuth-${var.name}"
  express_route_circuit_name = azurerm_express_route_circuit.this.name
  resource_group_name   = var.resource_group_name
}
