
locals {
  varDiags = {
    name                       = "testing-diag"
    log_analytics_workspace_id = ""
    resource_id                = ""
    #   logs_to_enable = ["none"]
  }
}

module "diagnosticSettings" {
  source = "./diagnosticSettings"

  name                       = "diags-${local.varDiags.name}"
  log_analytics_workspace_id = local.varDiags.log_analytics_workspace_id != "" ? local.varDiags.log_analytics_workspace_id : null
  resource_id                = local.varDiags.log_analytics_workspace_id == "" ? null : local.varDiags.resource_id
  #   logs_to_enable = local.varDiags.logs_to_enable # local.varDiags.log_analytics_workspace_id != [] ? local.varDiags.logs_to_enable : [] 
  # ["none","AllMetrics","VMProtectionAlerts",]

}

output "diags" {
  value = module.diagnosticSettings
}