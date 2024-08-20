
output "nsg_id" {
  value = local.nsg_id
}
output "module_vnet1" {
  value = {for kk, kv in module.vnet1 : 
            "${kv.name}" => {
                "name" = kv.name
                "resource_id" = kv.resource_id
                "subnets" = kv.subnets
                #kv.resource.body.properties.id
            }
  }

}
/*
    output "azurerm_network_security_group" {
    value = {for kk, kv in azurerm_network_security_group.this : 
                "${kv.name}" => {
                    "name" = kv.name
                    "id" = kv.id
                }
    }

    }
    output "azurerm_route_table" {
    value = {for kk, kv in azurerm_route_table.this : 
                "${kv.name}" => {
                    "name" = kv.name
                    "id" = kv.id
                }
    }

    }
    output "azurerm_resource_group" {
    value = {for kk, kv in azurerm_resource_group.this_my : 
                "${kv.name}" => {
                    "name" = kv.name
                    "id" = kv.id
                }
    }
    }
*/