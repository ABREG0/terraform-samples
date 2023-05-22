
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


resource "azurerm_virtual_hub_route_table" "example" {
  name           = var.name
  virtual_hub_id = var.virtual_hub_id
  labels         = var.labels
}