
data "azurerm_client_config" "this" {
}

variable "name" {
  type        = string
  description = "(required) describe your variable"
  default     = "ba-mtm-nonprod-wus2-01"
}

variable "resource_group_name" {
  type        = string
  description = "(required) describe your variable"
  default     = "rg-mtm-nonprod-wus2-01"
}
variable "location" {
  type        = string
  description = "(required) describe your variable"
  default     = "westus3"
}
variable "log_analytics_workspace_id" {
  type        = string
  description = "(optional) describe your variable"
  default     = null
}

variable "subnet_id" {
  type        = string
  description = "(required) describe your variable"
  default     = null
}

resource "azurerm_public_ip" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.this.id
  }
}