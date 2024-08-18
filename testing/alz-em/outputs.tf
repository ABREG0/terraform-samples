output "azurerm_route_table" {
  value = [for kk, kv in azurerm_route_table.this : {"id"= kv.id} ]
}
