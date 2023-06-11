
locals {
  environment = "prod"

  vwan = {
    vwan_id = null

    vawan_name          = "vwan-${local.environment}-westus3"
    resource_group_name = "rg-vwan"
    location            = "westus3"
    type                = "Standard"
  }

  region1 = {
    name                  = "vhub-r1-${local.environment}-westus3"
    location              = "westus3"
    address_prefix        = "10.21.224.0/24"
    ExR_circuit_name      = "exr-r1-${local.environment}-westus3"
    service_provider_name = "Equinix"
    peering_location      = "Silicon Valley" # "Equinix-Silicon-Valley"
    peering_type          = "AzurePrivatePeering"
    ExR_gw_name           = "exr-gw-r1-${local.environment}-westus3"

  }

  tags = {
    team        = "local-me"
    environment = "local-${local.environment}"
  }
}
data "azurerm_virtual_hub" "this" {
  name                = local.region1.name
  resource_group_name = data.azurerm_resource_group.this.name
}
data "azurerm_resource_group" "this" {
  name = local.vwan.resource_group_name
}
data "azurerm_virtual_hub_route_table" "AppZone0" {
  name                = "rt-AppZone0-r1-${local.environment}-${local.region1.location}"
  resource_group_name = data.azurerm_resource_group.this.name
  virtual_hub_name    = data.azurerm_virtual_hub.this.name
}
data "azurerm_virtual_network" "AppZone0" {
  name                = "vnet-AppZone0-${local.environment}-${local.region1.location}"
  resource_group_name = data.azurerm_resource_group.this.name
  
}


variable "associated_route_table_id" {
  type = string
  default = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/group1/providers/Microsoft.Network/virtualHubs/hub1/hubRouteTables/routeTable1"
}

variable "propagated_route_tables" {
  type = object({
    labels            = list(string)
    name              = string
    address_prefixes  = list(string)
    next_hop_ip_address = string
  })
  default =  {
      labels            = ["label1", "label2"]
      name              = "route1"
      address_prefixes  = ["10.0.0.0/24", "10.0.1.0/24"]
      next_hop_ip_address = "10.0.2.4"
    }
  
}
variable "routing" {
  type = list(object({
    associated_route_table_id  = optional(string)

      labels               = list(string)
      route_table_ids      = optional(list(string))
     
    static_vnet_route = optional(map(object({
      name                = optional(string)
      address_prefixes    = list(string)
      next_hop_ip_address = string
      })
    ))
  }))
  default = [ {
                associated_route_table_id = null
                
                  labels =[] #["AppZone0"]
                  route_table_ids = []
                  
                static_vnet_route = {
                  svr = {
                name              = "route1"
                address_prefixes  = ["10.0.0.0/24", "10.0.1.0/24"]
                next_hop_ip_address = "10.0.2.4"
                  }
                  }
               } 
            ]
}
locals {
  empty_list   = []
  empty_map    = {}
  empty_string = ""
}
resource "azurerm_virtual_hub_connection" "this" {
  name                      = "conn-${data.azurerm_virtual_network.AppZone0.name}"
  remote_virtual_network_id = data.azurerm_virtual_network.AppZone0.id
  virtual_hub_id            = data.azurerm_virtual_hub.this.id

    # Dynamic configuration blocks
  
  dynamic "routing" {
    for_each = var.routing
    content {
      # Optional attributes
      associated_route_table_id = lookup(routing.value, "associated_route_table_id", null)
      # dynamic "propagated_route_table" {
      #   for_each = lookup(routing.value, "propagated_route_table", local.empty_map)
      #   content {
          # Optional attributes
          # labels          = ["AppZone0"] #lookup(routing.value, "labels", local.empty_list)
          # route_table_ids = [] #lookup(routing.value, "route_table_ids", local.empty_list)
      #   }
      # }
      dynamic "static_vnet_route" {
        for_each = lookup(routing.value, "static_vnet_route", local.empty_map)
        content {
          # Optional attributes
          name                = lookup(static_vnet_route.value, "name", null)
          address_prefixes    = lookup(static_vnet_route.value, "address_prefixes", local.empty_list)
          next_hop_ip_address = lookup(static_vnet_route.value, "next_hop_ip_address", local.empty_string)
        }
      }
    }
  }
  
}
