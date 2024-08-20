locals {
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
    creating_nested_objects_vnets2 = {
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
output "creating_nested_objects_vnets2" {
      value = [for kk, kv in local.creating_nested_objects_vnets2 : kv
            # {
            # kk = kv
            # } 
        ]
    }
    
/*
    output "local_resource_groups" {
    value = [for kk, kv in local.resource_groups : kv
            # {
            # kk = kv
            # } 
        ]
    }
    output "creating_nested_objects_rt" {
      value = [for kk, kv in local.creating_nested_objects_rt2 : kv
            # {
            # kk = kv
            # } 
        ]
    }
    output "creating_nested_objects_nsg" {
      value = [for kk, kv in local.creating_nested_objects_nsg : kv.nsg
            # {
            # kk = kv
            # } 
        ]
    }

    output "creating_nested_objects_subnets" {
      value = {for kk, kv in local.creating_nested_objects_subnets : 
           kk => kv  
        }
    }

    output "local_flats" {
      value = local.flats
    }
    output "local_subnets" {
      value = local.subnets
    }
    output "local_vnets" {
      value = local.vnets
    }

    output "Gateway_subnet" {
      value = [for kk, kv in module.mod_vnet : 
           kv.subnets["GatewaySubnet"].id
        ] 
        # module.mod_vnet
    }
    output "var_sub_name" {
      value = {for kk, kv in var.hub_connection.west_fw_shared.resources.virtual_networks : 
           kk => kv  #[kk.virtual_networks].subnets
        
        }
        # module.mod_vnet
    }
*/
variable "hub_connection" {
  type = map(object({
    location = string
    namespace = string
    tags = map(string)
    resources = object({
    #   resource_group_name     = string
      virtual_networks = optional(object({
        name = string
        virtual_network_address_space = list(string)
        subnets = optional(list(object({
                    address_space                   = string
                    additional_service_endpoints    = optional(list(string))
                    default_outbound_access_enabled = optional(bool, true)
                    enable_private_link_support     = optional(bool, false)
                    name                            = string
                    # resource_group_name             = string
                    subnet_type                     = optional(string)
                    # virtual_network_name            = string

                    delegations = optional(list(object({
                    service_delegation = object({
                        name    = string
                        actions = list(string)
                    })
                    name = string
                    })))
            })))
      }))
      network_security_groups = optional(list(object({
        name                = string
        rules = optional(object({
            name = string
            address_space = list(string)
            }))
        })))
      route_tables = optional(map(object({
        name                = string
        rules = optional(object({
            name = string
            address_space = list(string)
            }))

        })))
      public_ip = optional(map(object({
            name                = string
            allocation_method   = string
            sku                 = string
        })))
    })
  })
 )
 default = {
    ohemr-rg-core_fw-shared-wus2-002 = {
        location = "westus2"
        namespace = "ohemr"
        tags = {
                "Environment"      = "nprd"
                }
        resources = {
            # resource_group_name = "ohemr-rg-core_fw-shared-wus2-002"            
            virtual_networks = {
                name = "ohemr-vnet-hub_fw-shared-wus2-002"
                virtual_network_address_space = ["10.150.192.0/23", "10.150.194.0/25"]
                subnets = [
                    {
                    name = "GatewaySubnet"
                    address_space = "10.150.195.0/24"
                    },
                    {
                        name             = "fw_ew_trust-shared-wus2-001"
                        address_space = "10.150.192.0/26"
                    },
                    # {
                    #     name             = "fw_ew_trust-test-wus2-001"
                    #     address_space = "10.150.192.64/26"
                    # },
                    # {
                    #     name             = "fw_ew_trust-backhaul-wus2-001"
                    #     address_space = "10.150.192.128/26"
                    # },
                    # # {
                    # #   name             = "fw_ew_mgmt-shared-wus2-001 "
                    # #   address_space = "10.150.192.192/27"
                    # # },
                    # {
                    #     name             = "rt-fw_ew_mgmt-shared-wus2-001"
                    #     address_space = "10.150.192.224/27"
                    # },
                    # {
                    #     name             = "fw_ingress_untrust-shared-wus2-001"
                    #     address_space = "10.150.193.0/26"
                    # },
                    # {
                    #     name             = "fw_ingress_trust-shared-wus2-001"
                    #     address_space = "10.150.193.64/26"
                    # },
                    # {
                    #     name             = "fw_ingress_trust-test-wus2-001"
                    #     address_space = "10.150.193.128/26"
                    # },
                    # {
                    #     name             = "fw_ingress_mgmt-shared-wus2-001"
                    #     address_space = "10.150.193.192/27"
                    # },
                    # {
                    #     name             = "fw_pe-shared-wus2-001"
                    #     address_space = "10.150.193.224/27"
                    # },
                    # {
                    #     name             = "inbound_pvtrsvlr-shared-wus2-001"
                    #     address_space = "10.150.194.0/26"
                    # },
                    # # {
                    # #   name             = "outbound_pvtrsvlr-shared-wus2-001"
                    # #   address_space = "10.150.143.64/26"
                    # # }

                ]
                
            }
            network_security_groups = [
                {
                name                = "ohemr-nsg-hub_fw-shared-wus2-002"
                },
                {
                name                = "ohemr-nsg-hub_fw-shared-wus2-002"
                }
            ]
            route_tables = {
                rt1 = {name                = "ohemr-rt-hub_fw-shared-wus2-002"}
                rt2 = {name                = "ohemr-rt-hub_fw-shared-wus2-002"}
            }
            public_ip = {
                pip1 =  {
                    name                = "ohemr-pip-wus2-002" # "ohemr-snet-fw_ew_trust-shared-wus2-001"
                    # resource_group_name = each.value.resources.resource_group_name
                    # location            = each.value.location
                    allocation_method   = "Static"
                    sku                 = "Standard"
                }
                pip2 =  {
                    name                = "ohemr-pip-wus2-002" # "ohemr-snet-fw_ew_trust-shared-wus2-001"
                    # resource_group_name = each.value.resources.resource_group_name
                    # location            = each.value.location
                    allocation_method   = "Static"
                    sku                 = "Standard"
                }
                
            }
        }
    }
    ohemr-rg-core_fw-shared-wus3-003 = {
        location = "westus3"
        namespace = "ohemr"
        tags = {
                "Environment"      = "nprd"
                }
        resources = {
            # resource_group_name = "ohemr-rg-core_fw-shared-wus3-003"            
            virtual_networks = {
                name = "ohemr-vnet-hub_fw-shared-wus3-003"
                virtual_network_address_space = ["10.150.192.0/23", "10.150.194.0/25"]
                subnets = [
                    {
                    name = "GatewaySubnet"
                    address_space = "10.150.195.0/24"
                    },
                    {
                        name             = "fw_ew_trust-shared-wus3-001"
                        address_space = "10.150.192.0/26"
                    },
                    # {
                    #     name             = "fw_ew_trust-test-wus3-001"
                    #     address_space = "10.150.192.64/26"
                    # },
                    # {
                    #     name             = "fw_ew_trust-backhaul-wus3-001"
                    #     address_space = "10.150.192.128/26"
                    # },
                    # # {
                    # #   name             = "fw_ew_mgmt-shared-wus3-001 "
                    # #   address_space = "10.150.192.192/27"
                    # # },
                    # {
                    #     name             = "rt-fw_ew_mgmt-shared-wus3-001"
                    #     address_space = "10.150.192.224/27"
                    # },
                    # {
                    #     name             = "fw_ingress_untrust-shared-wus3-001"
                    #     address_space = "10.150.193.0/26"
                    # },
                    # {
                    #     name             = "fw_ingress_trust-shared-wus3-001"
                    #     address_space = "10.150.193.64/26"
                    # },
                    # {
                    #     name             = "fw_ingress_trust-test-wus3-001"
                    #     address_space = "10.150.193.128/26"
                    # },
                    # {
                    #     name             = "fw_ingress_mgmt-shared-wus3-001"
                    #     address_space = "10.150.193.192/27"
                    # },
                    # {
                    #     name             = "fw_pe-shared-wus3-001"
                    #     address_space = "10.150.193.224/27"
                    # },
                    # {
                    #     name             = "inbound_pvtrsvlr-shared-wus3-001"
                    #     address_space = "10.150.194.0/26"
                    # },
                    # # {
                    # #   name             = "outbound_pvtrsvlr-shared-wus3-001"
                    # #   address_space = "10.150.143.64/26"
                    # # }

                ]
            }
            
            network_security_groups = [
                {
                name                = "ohemr-nsg-hub_fw-shared-wus2-003"
                },
                {
                name                = "ohemr-nsg-hub_fw-shared-wus2-003"
                }
            ]
            route_tables = {
                rt1 = {name                = "ohemr-rt-hub_fw-shared-wus2-003"}
                rt2 = {name                = "ohemr-rt-hub_fw-shared-wus2-003"}
            }
            public_ip = {
                pip1 =  {
                    name                = "ohemr-pip-wus2-003" # "ohemr-snet-fw_ew_trust-shared-wus2-001"
                    # resource_group_name = each.value.resources.resource_group_name
                    # location            = each.value.location
                    allocation_method   = "Static"
                    sku                 = "Standard"
                }
                pip2 =  {
                    name                = "ohemr-pip-wus2-003" # "ohemr-snet-fw_ew_trust-shared-wus2-001"
                    # resource_group_name = each.value.resources.resource_group_name
                    # location            = each.value.location
                    allocation_method   = "Static"
                    sku                 = "Standard"
                }
                
            }
        }
    }
  }
}