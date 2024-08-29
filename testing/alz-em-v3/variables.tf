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
            nsg_key= optional(string)
            rt_key= optional(string)
            additional_service_endpoints       = optional(list(string))
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
      gateway = optional(map(object({
            name                = string
            type   = string
            sku                 = string
            vnet_key = string

        })))
      public_ip = optional(map(object({
            name                = string
            allocation_method   = string
            sku                 = string
        })))
    })
  })
 )
 default = {}
}