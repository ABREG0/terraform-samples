variable "hub_connection" {
  type = map(object({
    location = string
    namespace = string
    tags = map(string)
    resources = object({
      virtual_networks = optional(map(object({
        name = string
        virtual_network_address_space = list(string)
        subnets = optional(map(object({
            name                            = string
            address_prefixes                   = list(string)
            additional_service_endpoints    = optional(list(string))
            default_outbound_access_enabled = optional(bool, true)
            enable_private_link_support     = optional(bool, false)
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
      })))
      network_security_groups = optional(map(object({
        name                = string
        rules = optional(object({
            name = string
            rules = optional(list(string))
            }))
        })))
      route_tables = optional(map(object({
        name                = string
        rules = optional(object({
            name = string
            rules = optional(list(string))
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
                ohemr-vnet-hub_fw-shared-wus2-002 = {
                    name = "ohemr-vnet-hub_fw-shared-wus2-002"
                    virtual_network_address_space = ["10.150.192.0/23", "10.150.194.0/25"]
                    subnets = {
                        "GatewaySubnet" = {
                        name = "GatewaySubnet"
                        address_prefixes = ["10.150.193.0/24",]
                        }
                        "fw_ew_trust-shared-wus2-001" = {
                            name             = "fw_ew_trust-shared-wus2-001"
                            address_prefixes = ["10.150.192.0/26",]
                        }
                        "fw_ew_trust-test-wus2-001" = {
                            name             = "fw_ew_trust-test-wus2-001"
                            address_prefixes = ["10.150.192.64/26",]
                        }
                        # {
                        #     name             = "fw_ew_trust-backhaul-wus2-001"
                        #     address_prefixes = ["10.150.192.128/26",]
                        # },
                        # # {
                        # #   name             = "fw_ew_mgmt-shared-wus2-001 "
                        # #   address_prefixes = ["10.150.192.192/27",]
                        # # },
                        # {
                        #     name             = "rt-fw_ew_mgmt-shared-wus2-001"
                        #     address_prefixes = ["10.150.192.224/27",]
                        # },
                        # {
                        #     name             = "fw_ingress_untrust-shared-wus2-001"
                        #     address_prefixes = ["10.150.193.0/26",]
                        # },
                        # {
                        #     name             = "fw_ingress_trust-shared-wus2-001"
                        #     address_prefixes = ["10.150.193.64/26",]
                        # },
                        # {
                        #     name             = "fw_ingress_trust-test-wus2-001"
                        #     address_prefixes = ["10.150.193.128/26",]
                        # },
                        # {
                        #     name             = "fw_ingress_mgmt-shared-wus2-001"
                        #     address_prefixes = ["10.150.193.192/27",]
                        # },
                        # {
                        #     name             = "fw_pe-shared-wus2-001"
                        #     address_prefixes = ["10.150.193.224/27",]
                        # },
                        # {
                        #     name             = "inbound_pvtrsvlr-shared-wus2-001"
                        #     address_prefixes = ["10.150.194.0/26",]
                        # },
                        # # {
                        # #   name             = "outbound_pvtrsvlr-shared-wus2-001"
                        # #   address_prefixes = ["10.150.143.64/26",]
                        # # }

                    }
              }
            }
            network_security_groups = {
                fw_ew_trust-shared-wus2-001 = {
                name                = "fw_ew_trust-shared-wus2-001"
                },
                fw_ew_trust-test-wus2-001 = {
                name                = "fw_ew_trust-test-wus2-001"
                }
            }
            route_tables = {
                fw_ew_trust-shared-wus2-001 = {name                = "fw_ew_trust-shared-wus2-001"}
                fw_ew_trust-test-wus2-001 = {name                = "fw_ew_trust-test-wus2-001"}
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
                    name                = "ohemr-pip-wus2-003" # "ohemr-snet-fw_ew_trust-shared-wus2-001"
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
               ohemr-vnet-hub_fw-shared-wus3-003 = {name = "ohemr-vnet-hub_fw-shared-wus3-003"
                virtual_network_address_space = ["10.150.192.0/23", "10.150.194.0/25"]
                subnets = {
                    "GatewaySubnet" = {
                    name = "GatewaySubnet"
                    address_prefixes = ["10.150.193.0/24",]
                    }
                    "fw_ew_trust-shared-wus3-001" = {
                        name             = "fw_ew_trust-shared-wus3-001"
                        address_prefixes = ["10.150.192.0/26",]
                    }
                    "fw_ew_trust-test-wus3-001" = {
                        name             = "fw_ew_trust-test-wus3-001"
                        address_prefixes = ["10.150.192.64/26",]
                    }
                    # {
                    #     name             = "fw_ew_trust-backhaul-wus3-001"
                    #     address_prefixes = ["10.150.192.128/26",]
                    # },
                    # # {
                    # #   name             = "fw_ew_mgmt-shared-wus3-001 "
                    # #   address_prefixes = ["10.150.192.192/27",]
                    # # },
                    # {
                    #     name             = "rt-fw_ew_mgmt-shared-wus3-001"
                    #     address_prefixes = ["10.150.192.224/27",]
                    # },
                    # {
                    #     name             = "fw_ingress_untrust-shared-wus3-001"
                    #     address_prefixes = ["10.150.193.0/26",]
                    # },
                    # {
                    #     name             = "fw_ingress_trust-shared-wus3-001"
                    #     address_prefixes = ["10.150.193.64/26",]
                    # },
                    # {
                    #     name             = "fw_ingress_trust-test-wus3-001"
                    #     address_prefixes = ["10.150.193.128/26",]
                    # },
                    # {
                    #     name             = "fw_ingress_mgmt-shared-wus3-001"
                    #     address_prefixes = ["10.150.193.192/27",]
                    # },
                    # {
                    #     name             = "fw_pe-shared-wus3-001"
                    #     address_prefixes = ["10.150.193.224/27",]
                    # },
                    # {
                    #     name             = "inbound_pvtrsvlr-shared-wus3-001"
                    #     address_prefixes = ["10.150.194.0/26",]
                    # },
                    # # {
                    # #   name             = "outbound_pvtrsvlr-shared-wus3-001"
                    # #   address_prefixes = ["10.150.143.64/26",]
                    # # }

                }
              }
            }
            network_security_groups = {
                fw_ew_trust-shared-wus3-001 = {
                name                = "fw_ew_trust-shared-wus3-001"
                },
                fw_ew_trust-test-wus3-001 = {
                name                = "fw_ew_trust-test-wus3-001"
                }
            }
            route_tables = {
                fw_ew_trust-shared-wus3-001 = {name                = "fw_ew_trust-shared-wus3-001"}
                fw_ew_trust-test-wus3-001 = {name                = "fw_ew_trust-test-wus3-001"}
            }
            public_ip = {
                pip1 =  {
                    name                = "ohemr-pip-wus3-003" # "ohemr-snet-fw_ew_trust-shared-wus2-001"
                    # resource_group_name = each.value.resources.resource_group_name
                    # location            = each.value.location
                    allocation_method   = "Static"
                    sku                 = "Standard"
                }
                pip2 =  {
                    name                = "ohemr-pip-wus3-004" # "ohemr-snet-fw_ew_trust-shared-wus2-001"
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