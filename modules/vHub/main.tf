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
variable "vwan_id" {
  type        = string
  description = "(required) describe your variable"
}
variable "address_prefix" {
  type        = string
  description = "(required) describe your variable"
}
variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(any)
  default     = {}
}

output "id" {
  value = azurerm_virtual_hub.this.id
}
output "name" {
  value = azurerm_virtual_hub.this.name
}

output "location" {
  value = azurerm_virtual_hub.this.location
}
variable "route" {
  type = list(object({
              address_prefixes    = list(string)
              next_hop_ip_address = string
            })
          )
  default = []
}

resource "azurerm_virtual_hub" "this" {

  provider = azurerm.connectivity


  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_wan_id      = var.vwan_id
  address_prefix      = var.address_prefix # "10.221.224.0/24"
  tags           = var.tags

  # Dynamic configuration blocks
     dynamic "route" {
      for_each = var.route
      content {
        # Mandatory attributes
        address_prefixes    = route.value["address_prefixes"]
        next_hop_ip_address = route.value["next_hop_ip_address"]
      }
    }
