
variable "name" {
  type        = string
  description = "(required) describe your variable"
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "Required: workspace to send logs"
  default     = null
}

variable "resource_id" {
  description = "Required: id"
  default     = "" # []
}

data "azurerm_monitor_diagnostic_categories" "this" {
  resource_id = var.resource_id 
}

# variable "logs_to_enable" {
#   type = list(string)
#   description = "Optional: logs to enabled"
#   default = []
# }

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = var.name
  target_resource_id         = var.resource_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  
  dynamic "enabled_log" {
    iterator = log
    for_each = data.azurerm_monitor_diagnostic_categories.this.log_category_types
    content {
      category = log.value
      retention_policy {
        days    = 30
        enabled = true
      }
    }
  }

  dynamic "metric" {
    iterator = metric
    for_each = data.azurerm_monitor_diagnostic_categories.this.metrics
    content {
      category = metric.value
      enabled  =  metric.value != null ? true : false
      retention_policy {
        days    = 30
        enabled = true
      }
    }
  }
  
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      # tags, 
      log, metric
    ]
  }

}

output "diag_catgories" {
  value = data.azurerm_monitor_diagnostic_categories.this
}
output "logs" {
  value = azurerm_monitor_diagnostic_setting.this
}