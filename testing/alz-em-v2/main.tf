
# resource "azurerm_subnet_route_table_association" "example" {
#   subnet_id      = azurerm_subnet.example.id
#   route_table_id = azurerm_route_table.example.id
# }

# This is required for resource modules
resource "azurerm_resource_group" "this_my" {
    for_each = {for kk, kv in local.resource_groups : kk => kv
        } # {for kk, kv in local.resource_groups.RGs : kk => kv}
  location = each.value.location
  name     = each.value.resource_group_name
}
# This is required for resource modules
resource "azurerm_resource_group" "this_my2" {
    for_each = {for kk, kv in local.resource_groups2.RGs : kk => kv
        } # {for kk, kv in local.resource_groups.RGs : kk => kv}
  location = each.value.location
  name     = format("%s-${each.value.resource_group_name}", "v2-")
}

    #Defining the first virtual network (vnet-1) with its subnets and settings.
    module "vnet1" {
        depends_on = [ azurerm_resource_group.this_my, azurerm_network_security_group.this, azurerm_route_table.this, ]
        for_each = local.creating_nested_objects_vnets2 # {for kk, kv in local.creating_nested_objects_vnets2 : kk => kv }
        source              = "Azure/avm-res-network-virtualnetwork/azurerm"
        location            = each.value.location
        name                = each.value.vnets.name
        resource_group_name = each.value.resource_group_name

        address_space = each.value.vnets.virtual_network_address_space

        dns_servers = {
            dns_servers = ["8.8.8.8"]
        }
        flow_timeout_in_minutes = 30

        subnets = each.value.vnets.subnets
            /*{
                subnet0 = {
                    name                            = "subnet1"
                    default_outbound_access_enabled = false
                    #sharing_scope                   = "Tenant"  #NOTE: This preview feature requires approval, leaving off in example: Microsoft.Network/EnableSharedVNet
                    address_prefixes = ["10.150.192.0/24", "10.150.193.0/24"]
                }
                # subnet1 = {
                #     name                            = "${module.naming.subnet.name_unique}1"
                #     address_prefixes                = ["192.168.1.0/24"]
                #     default_outbound_access_enabled = false
                #     delegation = [{
                #         name = "Microsoft.Web.serverFarms"
                #         service_delegation = {
                #         name = "Microsoft.Web/serverFarms"
                #         }
                #     }]
                #     nat_gateway = {
                #         id = azurerm_nat_gateway.this.id
                #     }
                #     network_security_group = {
                #         id = azurerm_network_security_group.https.id
                #     }
                #     route_table = {
                #         id = azurerm_route_table.this.id
                #     }
                #     service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
                #     service_endpoint_policies = {
                #         policy1 = {
                #         id = azurerm_subnet_service_endpoint_storage_policy.this.id
                #         }
                #     }
                #     role_assignments = {
                #         role1 = {
                #         principal_id               = azurerm_user_assigned_identity.this.principal_id
                #         role_definition_id_or_name = "Contributor"
                #         }
                # }
            
            }*/
    /*

        ddos_protection_plan = {
            id = azurerm_network_ddos_protection_plan.this.id
            # due to resource cost
            enable = false
        }

        role_assignments = {
            role1 = {
            principal_id               = azurerm_user_assigned_identity.this.principal_id
            role_definition_id_or_name = "Contributor"
            }
        }

        enable_vm_protection = true

        encryption = {
            enabled = true
            #enforcement = "DropUnencrypted"  # NOTE: This preview feature requires approval, leaving off in example: Microsoft.Network/AllowDropUnecryptedVnet
            enforcement = "AllowUnencrypted"
        }

        diagnostic_settings = {
            sendToLogAnalytics = {
            name                           = "sendToLogAnalytics"
            workspace_resource_id          = azurerm_log_analytics_workspace.this.id
            log_analytics_destination_type = "Dedicated"
            }
        }
     */
    }

    #Creating a Route Table with a unique name in the specified location.
    resource "azurerm_route_table" "this" {
        depends_on = [ azurerm_resource_group.this_my,  ]
        for_each = {for kk, kv in local.creating_nested_objects_rt2 : kv.name => kv
        }
        location            = each.value.location
        name                = format("%s-${each.value.name}", "${each.value.namespace}-rt")
        resource_group_name = each.value.resource_group_name
    }

    resource "azurerm_network_security_group" "this" {
        depends_on = [ azurerm_resource_group.this_my,  ]
        for_each = {for kk, kv in local.creating_nested_objects_nsg2 : kv.name => kv
        }
        location            = each.value.location
        name                =  each.value.name #format("%s-${each.value.name}", "${each.value.namespace}-nsg")
        resource_group_name = each.value.resource_group_name

        security_rule {
            access                     = "Allow"
            destination_address_prefix = "*"
            destination_port_range     = "443"
            direction                  = "Inbound"
            name                       = "AllowInboundHTTPS"
            priority                   = 100
            protocol                   = "Tcp"
            source_address_prefix      =  "10.2.3.1" # jsondecode(data.http.public_ip.response_body).ip
            source_port_range          = "*"
        }
    }

    ## Section to provide a random Azure region for the resource group
    # This allows us to randomize the region for the resource group.
    module "regions" {
    source  = "Azure/regions/azurerm"
    version = "~> 0.3"
    }

    # This allows us to randomize the region for the resource group.
    resource "random_integer" "region_index" {
    max = length(module.regions.regions) - 1
    min = 0
    }
    ## End of section to provide a random Azure region for the resource group

    # This ensures we have unique CAF compliant names for our resources.
    module "naming" {
    source  = "Azure/naming/azurerm"
    version = "~> 0.3"
    }

/*

    # This is required for resource modules
    resource "azurerm_resource_group" "this" {
    location = module.regions.regions[random_integer.region_index.result].name
    name     = module.naming.resource_group.name_unique
    }
    # Creating a DDoS Protection Plan in the specified location.
    resource "azurerm_network_ddos_protection_plan" "this" {
    location            = azurerm_resource_group.this.location
    name                = module.naming.network_ddos_protection_plan.name_unique
    resource_group_name = azurerm_resource_group.this.name
    }

    #Creating a NAT Gateway in the specified location.
    resource "azurerm_nat_gateway" "this" {
    location            = azurerm_resource_group.this.location
    name                = module.naming.nat_gateway.name_unique
    resource_group_name = azurerm_resource_group.this.name
    }

    # Fetching the public IP address of the Terraform executor used for NSG
    data "http" "public_ip" {
    method = "GET"
    url    = "http://api.ipify.org?format=json"
    }
    resource "azurerm_user_assigned_identity" "this" {
    location            = azurerm_resource_group.this.location
    name                = module.naming.user_assigned_identity.name_unique
    resource_group_name = azurerm_resource_group.this.name
    }

    resource "azurerm_storage_account" "this" {
    account_replication_type = "ZRS"
    account_tier             = "Standard"
    location                 = azurerm_resource_group.this.location
    name                     = module.naming.storage_account.name_unique
    resource_group_name      = azurerm_resource_group.this.name
    }

    resource "azurerm_subnet_service_endpoint_storage_policy" "this" {
    location            = azurerm_resource_group.this.location
    name                = "sep-${module.naming.unique-seed}"
    resource_group_name = azurerm_resource_group.this.name

    definition {
        name = "name1"
        service_resources = [
        azurerm_resource_group.this.id,
        azurerm_storage_account.this.id
        ]
        description = "definition1"
        service     = "Microsoft.Storage"
    }
    }

    resource "azurerm_log_analytics_workspace" "this" {
    location            = azurerm_resource_group.this.location
    name                = module.naming.log_analytics_workspace.name_unique
    resource_group_name = azurerm_resource_group.this.name
    }

    module "vnet2" {
    source              = "Azure/avm-res-network-virtualnetwork/azurerm"
    resource_group_name = azurerm_resource_group.this.name
    location            = azurerm_resource_group.this.location
    name                = "${module.naming.virtual_network.name_unique}2"
    address_space       = ["10.0.0.0/27"]

    encryption = {
        enabled     = true
        enforcement = "AllowUnencrypted"
    }

    peerings = {
        peertovnet1 = {
        name                                  = "${module.naming.virtual_network_peering.name_unique}-vnet2-to-vnet1"
        remote_virtual_network_resource_id    = module.vnet1.resource_id
        allow_forwarded_traffic               = true
        allow_gateway_transit                 = true
        allow_virtual_network_access          = true
        do_not_verify_remote_gateways         = false
        enable_only_ipv6_peering              = false
        use_remote_gateways                   = false
        create_reverse_peering                = true
        reverse_name                          = "${module.naming.virtual_network_peering.name_unique}-vnet1-to-vnet2"
        reverse_allow_forwarded_traffic       = false
        reverse_allow_gateway_transit         = false
        reverse_allow_virtual_network_access  = true
        reverse_do_not_verify_remote_gateways = false
        reverse_enable_only_ipv6_peering      = false
        reverse_use_remote_gateways           = false
        }
    }
    }
*/