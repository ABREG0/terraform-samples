
# variable "subnets" {
#   type = map(object({
#     name                                      = string
#     route_table_id                            = string
#     destinations_type = string
#     destinations                         = list(string)
#     next_hop_type                                      = string
#     next_hop                            = string
#   }))
# }

variable "name" {
  type        = string
  description = "(required) describe your variable"
  default     = "vwan-dev-westus3"
}
variable "route_table_id" {
  type        = string
  description = "(required) describe your variable"
}
variable "destinations_type" {
  type        = string
  description = "(required) describe your variable"
  default     = "ResourceId" # "CIDR" , "ResourceId" , "Service"
}
variable "destinations" {
  type        = list(string)
  description = "(required) describe your variable"
  default     = []
}
variable "next_hop_type" {
  type        = string
  description = "(required) describe your variable"
  default     = "ResourceId"
}
variable "next_hop" {
  type        = string
  description = "(required) describe your variable"
}
output "id" {
  value = azurerm_virtual_hub_route_table_route.this.id
}
output "name" {
  value = azurerm_virtual_hub_route_table_route.this.name
}

resource "azurerm_virtual_hub_route_table_route" "this" {
  route_table_id = var.route_table_id

  name              = var.name
  destinations_type = var.destinations_type
  destinations      = var.destinations
  next_hop_type     = var.next_hop_type
  next_hop          = var.next_hop
}