# output "nsg_by_id" {
#   value = azurerm_network_security_group.this 
# #   azurerm_network_security_group.this["nsg-fw_ew_trust-test-wus2-001"].id
# }
output "associate" {
  value = { for top_key, top_value in flatten([
                for net_key, net_v in local.creating_nested_objects_vnets2 : [
                    for snet_k, snet_v in net_v.subnets : {
                        vnet = net_v.name
                        # "${snet_v.rt_key}"
                        rt = snet_v.rt_key
                        # "${snet_v.nsg_key}"        
                        nsg = snet_v.nsg_key
                        # "${snet_v.name}" 
                        snet = snet_v.name
                        snet_id = module.vnet1[net_v.name].subnets[snet_v.name].resource_id
                        nsg_id = azurerm_network_security_group.this[snet_v.nsg_key].id
                        rt_id = azurerm_route_table.this[snet_v.rt_key].id
                    } if snet_v.rt_key != null || snet_v.nsg_key != null
                ]
              ]) : "${top_key}" => top_value
    }
  #module.vnet1["ohemr-vnet-hub_fw-shared-wus2-002"].subnets["GatewaySubnet"].resource_id
}
# # output "rt_id" {
# #   value = local.rt_id
# # }
# output "creating_nested_objects_subnets" {
#   value = {for kk, kv in local.creating_nested_objects_nsg2 : kv.name => kv}
# }
# output "associate" {
#   value = azurerm_network_security_group.this
# }
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