
# output "nsg_id" {
#   value = local.nsg_id["fw_ew_trust-test-wus2-001"].id
# }
# output "rt_id" {
#   value = local.rt_id
# }
# output "creating_nested_objects_subnets" {
#   value = {for kk, kv in local.creating_nested_objects_nsg2 : kv.name => kv["fw_ew_trust-test-wus2-001"].id}
# }
output "associate" {
  value = azurerm_network_security_group.this["fw_ew_trust-test-wus2-001"].id
}
/*
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