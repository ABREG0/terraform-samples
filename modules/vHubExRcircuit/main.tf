
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
  default     = "westus3"
}
variable "peering_location" {
  type        = string
  description = "(required) describe your variable"
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
variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(any)
  default     = {}
}
resource "azurerm_express_route_circuit" "this" {
  name                  = var.name
  resource_group_name   = var.resource_group_name
  location              = var.location
  service_provider_name = var.service_provider_name
  peering_location      = var.peering_location
  bandwidth_in_mbps     = var.bandwidth_in_mbps

  allow_classic_operations = false

  sku {
    tier   = var.tier
    family = var.family
  }

  tags = var.tags
}