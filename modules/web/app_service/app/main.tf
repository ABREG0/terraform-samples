

resource "azurerm_app_service_virtual_network_swift_connection" "this" {
  count = var.subnet_id != null ? 1 : 0
  app_service_id = azurerm_app_service.this.id
  subnet_id      = var.subnet_id
}
resource "azurerm_app_service" "this" {
  name                         = var.name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  app_service_plan_id          = var.app_service_plan_id
  
  https_only = true

  # key_vault_reference_identity_id = var.key_vault_reference_identity_id

  site_config {
      dotnet_framework_version     = var.site_config.dotnet_framework_version
      scm_type                     = var.site_config.scm_type
      # source_control = null 
      vnet_route_all_enabled = true
      scm_use_main_ip_restriction = true

      dynamic "ip_restriction" { 
        for_each = var.site_config.ip_restriction
          content {
                  name = ip_restriction.value.name
                  priority = ip_restriction.value.priority
                  action = ip_restriction.value.action
                  ip_address                = lookup(ip_restriction.value, "ip_address", null)
                  virtual_network_subnet_id = lookup(ip_restriction.value, "virtual_network_subnet_id", null)
                  # ip_address = ip_restriction.value.ip_address
          }
      }
  }

  app_settings = var.app_settings

  dynamic "connection_string" {
    for_each = var.connection_string
      content {
        name  = connection_string.value["name"]
        type  = connection_string.value["type"]
        value = connection_string.value["value"]
      }
  }
  dynamic identity {
    for_each = length(var.identity.type) > 0 || var.identity.type == "UserAssigned" ? [var.identity.type] : []
    content {
      type         = var.identity.type
      identity_ids = length(var.identity.identity_ids) > 0 ? var.identity.identity_ids : []
    }
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
