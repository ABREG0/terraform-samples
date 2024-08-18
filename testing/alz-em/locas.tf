locals {
    creating_nested_objects_rt = {
        for rg_key, rg_value in var.hub_connection :
        rg_key => {  
                resource_group_name = rg_key
                virtual_network_name = rg_value.resources.virtual_networks.name
                location = rg_value.location
                tags = rg_value.tags
                "rt" = rg_value.resources.route_tables
        }
    }
    
    creating_nested_objects_rt2 = flatten([
        for rg_key, rg_value in var.hub_connection :
        [ 
            for rt_key, rt_value in rg_value.resources.route_tables: {
                resource_group_name = rg_key
                virtual_network_name = rg_value.resources.virtual_networks.name
                location = rg_value.location
                name = rt_value.name
                rules = rt_value.rules
                # tags = rg_value.tags
                # "rt" = rg_value.resources.route_tables
                }
        ]
    ])
    resource_groups = [
     for rg_key, rg_value in var.hub_connection :
        {  
            resource_group_name = rg_key
            location = rg_value.location
            tags = rg_value.tags
        }
    # for item_key, item_value in var.hub_connection : 
    # item_key => item_key # item_value.resources
    # if resource.west_fw_shared_wus2 &&
    # contains(["connectivity", "ddos", "dns"], resource.west_fw_shared_wus2)
    ]
    resource_groups2 = {
     for rg_key, rg_value in var.hub_connection :
        "RGs" => {  
            resource_group_name = rg_key
            location = rg_value.location
            tags = rg_value.tags
        }...
    # for item_key, item_value in var.hub_connection : 
    # item_key => item_key # item_value.resources
    # if resource.west_fw_shared_wus2 &&
    # contains(["connectivity", "ddos", "dns"], resource.west_fw_shared_wus2)
    }
    # object variable to list
    flats = { for top_key, top_value in [
                for index_key, kv in var.hub_connection : [
                    for rk, rv in kv.resources : {
                        "${rk}" = rv
                        resource_group_name         = index_key
                        location = kv.location
                    }
                ]
              ] : "${top_key}" => top_value
    }

    creating_nested_objects = {
        for rg_key, rg_value in var.hub_connection :
        rg_key => {  
            for k, v in rg_value.resources: k => {
                    resource_group_name = rg_key
                    location = rg_value.location
                    tags = rg_value.tags
                    "${k}" = v
                }
        }
    }
    creating_nested_objects-00 = {
        for rg_key, rg_value in var.hub_connection :
        rg_key => {  
                resource_group_name = rg_key
                location = rg_value.location
                tags = rg_value.tags
                "all_resources" = rg_value.resources
        }
    }
    creating_nested_objects_vnets = {
        for rg_key, rg_value in var.hub_connection :
        rg_key => {  
                resource_group_name = rg_key
                location = rg_value.location
                tags = rg_value.tags
                "vnets" = rg_value.resources.virtual_networks
        }
    }
    creating_nested_objects_nsg = {
        for rg_key, rg_value in var.hub_connection :
        rg_key => {  
                resource_group_name = rg_key
                virtual_network_name = rg_value.resources.virtual_networks.name
                location = rg_value.location
                tags = rg_value.tags
                "nsg" = rg_value.resources.network_security_groups
        }
    }
    creating_nested_objects_subnets = {
        for rg_key, rg_value in var.hub_connection :
        rg_key => {  
                resource_group_name = rg_key
                virtual_network_name = rg_value.resources.virtual_networks.name
                location = rg_value.location
                tags = rg_value.tags
                "subnets" = rg_value.resources.virtual_networks.subnets
        }
    }

    subnets = { for subnet in var.hub_connection.ohemr-rg-core_fw-shared-wus2-002.resources.virtual_networks.subnets : subnet.name => subnet }

    vnets = [ for rgK, rgV in var.hub_connection : {
      for res_k, res_v in rgV.resources.virtual_networks : #{res_k = res_v} 
            "${res_k}" => res_v
        # if res_k == "virtual_networks"
    } 
    ]
    top_key = { for rgK, rgV in  {
      for res_k, res_v in var.hub_connection :
            res_k => "${res_k}"
        # if res_k == "virtual_networks"
        } : "topKey" =>  rgV...
    }
}
