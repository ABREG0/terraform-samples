
resource "azurerm_app_service_plan" "this" {
  name                         = var.name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  kind                         = var.kind
  maximum_elastic_worker_count = var.maximum_elastic_worker_count
  per_site_scaling             = var.per_site_scaling 
  zone_redundant               = var.zone_redundant   

  sku {
    tier = var.tier
    size = var.size
  }
  tags = var.tags
  
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      # tags, 
      tags,
    ]
  }
}
