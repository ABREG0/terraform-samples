variable "name" {
  description = "Name of the vnet to create"
  default     = ""
}
variable "address_space" {
  description = "The address space that is used by the virtual network."
  type        = list(string)
  # default     = ["10.240.0.0/22"]
}

# If no values specified, this defaults to Azure DNS 
variable "dns_servers" {
  description = "The DNS servers to be used with vNet. list"
  type        = list(string)
  #default     = []
}
variable "resource_group_name" {
  description = "Default resource group name that the network will be created in."
  #default     = "vnets"
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  #default     = "westus"
}

variable "diagnosticSettings" {
  type = object({
    log_analytics_workspace_id = string
  })
  default = {
    log_analytics_workspace_id = null
  }
}

# variable "log_analytics_workspace_id" {
#   description = "Required: workspace to send logs" 
#   type = string
#   default = ""
# }

# variable "logs_to_enable" {
#   type = list(string)
#   default = [ ]
# }

variable "ddos_protection_plan" {
  type    = any
  default = []
}

variable "subnets" {
  type = map(object({
    name                                      = string
    address_prefix                            = string
    service_endpoints                         = list(string)
    private_endpoint_network_policies_enabled = bool
    delegation = list(object({
      name = string
      service_delegation = list(object({
        name    = string
        actions = list(string)
      }))
    }))
  }))
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(any)
  default     = {}
}
output "id" {
  description = "The id of the newly created vNet"
  value       = azurerm_virtual_network.this.id
}

output "name" {
  description = "The Name of the newly created vNet"
  value       = azurerm_virtual_network.this.name
}

output "location" {
  description = "The location of the newly created vNet"
  value       = azurerm_virtual_network.this.location
}

output "address_space" {
  description = "The address space of the newly created vNet"
  value       = azurerm_virtual_network.this.address_space
}

output "subnetsIDs" {
  description = "The ids of subnets created inside the newl vNet"
  value       = { for strOut, sub in azurerm_subnet.subnet : strOut => sub.id }
}

output "subnetsNames" {
  description = "The ids of subnets created inside the newl vNet"
  value       = { for strOut, sub in azurerm_subnet.subnet : strOut => sub.name }
}

output "subnets" {
  value = azurerm_subnet.subnet
}
output "virtualNetwork" {
  value = azurerm_virtual_network.this
}

# output "diag_catgories" {
#   value = module.diag.diag_catgories
# }