output "id" {
  value = azurerm_app_service.this.id
}
output "name" {
  value = azurerm_app_service.this.name
}
output "location" {
  value = azurerm_app_service.this.location
}
output "appService" {
  value = azurerm_app_service.this
}
output "diag_catgories" {
  value = module.diag.diag_catgories
}