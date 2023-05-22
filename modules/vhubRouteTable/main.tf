
variable "name" {
  type        = string
  description = "(required) describe your variable"
  default     = "test-route-table"
}
variable "virtual_hub_id" {
  type        = string
  description = "(required) describe your variable"
  default     = null
}
variable "labels" {
  type        = list(string)
  description = "(required) describe your variable"
  default     = ["appName"]
}

output "id" {
  value = azurerm_virtual_hub_route_table.this.id
}
output "name" {
  value = azurerm_virtual_hub_route_table.this.name
}
output "labels" {
  value = azurerm_virtual_hub_route_table.this.labels
}
resource "azurerm_virtual_hub_route_table" "this" {
  name           = var.name
  virtual_hub_id = var.virtual_hub_id
  labels         = var.labels
}