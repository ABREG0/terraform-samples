variable "name" {
  type        = string
  description = "(required) describe your variable"
  default     = "vwan-dev-westus3"
}
variable "resource_group_name" {
  type        = string
  description = "(required) describe your variable"
  default     = "rg-dev-westus3"
}
variable "location" {
  type        = string
  description = "(required) describe your variable"
  default     = "westus3"
}
variable "type" {
  type        = string
  description = "(required) describe your variable"
  default     = "Standard"
}
variable "settings" {
  type = object({
    disable_vpn_encryption            = bool
    allow_branch_to_branch_traffic    = bool
    office365_local_breakout_category = string
    log_analytics_workspace_id        = string
  })
}
variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(any)
  default     = {}
}
resource "azurerm_virtual_wan" "this" {
  provider = azurerm.connectivity

  # Mandatory resource attributes
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Optional resource attributes
  disable_vpn_encryption            = var.settings.disable_vpn_encryption                                                                              # true 
  allow_branch_to_branch_traffic    = var.settings.allow_branch_to_branch_traffic                                                                      # false 
  office365_local_breakout_category = var.settings.office365_local_breakout_category == null ? "None" : var.settings.office365_local_breakout_category # "None" # Optimize, OptimizeAndAllow, All, None 
  type                              = var.type  
  tags = var.tags                                                                                                       # "Standard" # "Basic"
}
output "id" {
  value = azurerm_virtual_wan.this.id
}
output "name" {
  value = azurerm_virtual_wan.this.name
}

output "location" {
  value = azurerm_virtual_wan.this.location
}