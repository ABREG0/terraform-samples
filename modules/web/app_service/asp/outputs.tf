output "id" {
  value = azurerm_app_service_plan.this.id
}
output "name" {
  value = azurerm_app_service_plan.this.name
}
output "location" {
  value = azurerm_app_service_plan.this.location
}
output "logAnalytics" {
  value = azurerm_app_service_plan.this
}
output "diag_catgories" {
  value = module.diag.diag_catgories
}