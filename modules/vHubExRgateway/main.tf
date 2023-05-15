
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
variable "virtual_hub_id" {
  type        = string
  description = "(required) describe your variable"
}
variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(any)
  default     = {}
}
resource "azurerm_express_route_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_hub_id      = var.virtual_hub_id
  scale_units         = 2

  tags = var.tags
}
output "id" {
  value = azurerm_express_route_gateway.this.id
}
output "name" {
  value = azurerm_express_route_gateway.this.name
}

output "location" {
  value = azurerm_express_route_gateway.this.location
}