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