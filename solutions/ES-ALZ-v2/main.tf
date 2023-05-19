
locals {
  environment = "prod"
  
  vwan = {
          vwan_id = null

          vawan_name = "vwan-${local.environment}-westus3"
          resource_group_name = "rg-vwan"
          location            = "westus3"
          type                = "Standard"
         }

  region1 = {
    name = "vhub-r1-${local.environment}-westus3"
    location = "westus3"
    address_prefix        = "10.21.224.0/24"
    ExR_circuit_name      = "exr-r1-${local.environment}-westus3"
    service_provider_name = "Equinix"
    peering_location      = "Silicon Valley" # "Equinix-Silicon-Valley"
    peering_type          = "AzurePrivatePeering"
    ExR_gw_name           = "exr-gw-${local.environment}-westus3"
    
  }

  tags = {
      team = "local-me"
      environment = "local-${local.environment}"
    }
}

module "resource_group" {
  source   = "../../modules/resourceGroup"
  name     = local.vwan.resource_group_name # "rg-dev-westus3"
  location = local.vwan.location # "westus3"
  
  tags = merge(
    {
      team = "me"
      environment = local.environment
    },
    local.tags
  )
}
resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-${local.environment}-westus3"
  resource_group_name = module.resource_group.name     # "rg-dev-westus3"
  location            = module.resource_group.location # "westus3"
  sku                 = "PerGB2018"
  retention_in_days   = 30
  internet_ingestion_enabled    = true
  internet_query_enabled        = true

}

module "rg_diag_vnet_r1" {
  source = "../../modules/diagnosticSettings"
  name = "${module.vnet_r1.name}-r1-diag"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  resource_id = module.vnet_r1.id
} 
module "rg_diag_vnet_r2" {
  source = "../../modules/diagnosticSettings"
  name = "${module.vnet_r2.name}-r2-diag"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  resource_id = module.vnet_r2.id
} 

module "vwan" {
  source              = "../../modules/vwan"
  name                = local.vwan.vawan_name
  resource_group_name = module.resource_group.name     # "rg-dev-westus3"
  location            = module.resource_group.location # "westus3"
  type                = local.vwan.type
  settings = {
    disable_vpn_encryption            = true
    allow_branch_to_branch_traffic    = true
    office365_local_breakout_category = "All" # "None" # Optimize, OptimizeAndAllow, All, None 
    log_analytics_workspace_id        = null
  }
  
  tags = merge(
    {
      team = "me"
      environment = local.environment
    },
    local.tags
  )
}
module "vhub_r1" {
  source              = "../../modules/vHub"
  name                = local.region1.name # 
  resource_group_name = module.resource_group.name     # "rg-dev-westus3"
  location            = local.region1.location # "westus3"
  vwan_id             = module.vwan.id
  address_prefix      = local.region1.address_prefix
  route = [ 
        {
            address_prefixes = ["10.21.20.0/24"]
            next_hop_ip_address = "10.20.2.10" #"vhub-dev-westus3-with-${module.vnet.name}"
        },
        {
            address_prefixes = ["10.21.24.0/24"]
            next_hop_ip_address = "10.20.3.10" #"vhub-dev-westus3-with-${module.vnet.name}"
        } 
    ]
  
  tags = merge(
    {
      team = "me"
      environment = local.environment
    },
    local.tags
  )
}
module "ExR_circuit_r1" {
    source = "../../modules/vHubExRcircuit"
  name                  = local.region1.ExR_circuit_name # 
  resource_group_name   = module.resource_group.name     # "rg-dev-westus3"
  location              = local.region1.location
  service_provider_name = local.region1.service_provider_name
  peering_location      = local.region1.peering_location # "Silicon Valley" # "Equinix-Silicon-Valley"
  bandwidth_in_mbps     = 50
  
  # express_route_port_id = module.ExR_circuit_port.id
  # bandwidth_in_gbps     = 10

  allow_classic_operations = false

    tier   = "Standard"
    family = "MeteredData"

  tags = {
      team = "local-me"
      environment = "local-${local.environment}"
    }
}
module "ExR_circuit_peering_r1" {
  source = "../../modules/vHubExRcircuitPeering"

  peering_type                  = local.region1.peering_type
  express_route_circuit_name    = module.ExR_circuit_r1.name
  resource_group_name           = module.resource_group.name     # "rg-dev-westus3"
  shared_key                    = "ItsASecret"
  peer_asn                      = 100
  primary_peer_address_prefix   = "192.168.1.0/30"
  secondary_peer_address_prefix = "192.168.1.0/30"
  vlan_id                       = 100
  
}
module "ExR_gw_r1" {
  source = "../../modules/vHubExRgateway"
  name                = local.region1.ExR_gw_name
  resource_group_name = module.resource_group.name     # "rg-dev-westus3"
  location            = local.region1.location
  virtual_hub_id      = module.vhub_r1.id

  tags = merge(
    {
      team = "me"
      environment = local.environment
    },
    local.tags
  )
}
module "vnet_r1" {

  source = "../../modules/network/vnet"
  name                = "vnet-${local.environment}-${local.region1.location}"
  resource_group_name = module.resource_group.name     # "rg-dev-westus3"
  location            = local.region1.location
  address_space        = ["10.67.100.0/22", "10.67.104.0/22"] # each.value.address_space
  dns_servers          = []
  ddos_protection_plan = [] # [{ id = module.ddos.id, enable = true }, ]

  subnets = {
  plpe = {
    name                                      = "plpe"
    address_prefix                            = "10.67.100.0/24"
    service_endpoints                         = ["Microsoft.AzureActiveDirectory", "Microsoft.ContainerRegistry", "Microsoft.AzureCosmosDB", "Microsoft.EventHub", "Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.Web"]
    private_endpoint_network_policies_enabled = false
    delegation                                = []
    },
  }

  tags = merge(
    {
      team = "me"
      environment = local.environment
    },
    local.tags
  )

}
module "vhub_connection_r1" {
  source = "../../modules/vwanHubConnection"
  name = "${module.vhub_r1.name}-with-${module.vnet_r1.name}"
  remote_virtual_network_id = module.vnet_r1.id
  virtual_hub_id = module.vhub_r1.id 
}

locals {
    region2 = {
    name = "vhub-r2-${local.environment}-westus"
    location = "westus"
    address_prefix        = "10.221.224.0/24"
    ExR_circuit_name      = "exr-r2-${local.environment}-westus"
    service_provider_name = "Equinix"
    peering_location      = "Seattle" # "Equinix-Silicon-Valley"
    peering_type          = "AzurePrivatePeering"
    ExR_gw_name           = "exr-gw-r2-${local.environment}-westus"
  }
  
}
module "vhub_r2" {
  source              = "../../modules/vHub"
  name                = local.region2.name # 
  resource_group_name = module.resource_group.name     # "rg-dev-westus3"
  location            = local.region2.location # "westus3"
  vwan_id             = module.vwan.id
  address_prefix      = local.region2.address_prefix
  route = [ 
        {
            address_prefixes = ["10.220.20.0/24"]
            next_hop_ip_address = "10.20.2.10" #"vhub-dev-westus3-with-${module.vnet.name}"
        },
        {
            address_prefixes = ["10.220.24.0/24"]
            next_hop_ip_address = "10.20.20.10" #"vhub-dev-westus3-with-${module.vnet.name}"
        } 
    ]
  
  tags = merge(
    {
      team = "me"
      environment = local.environment
    },
    local.tags
  )

}
module "ExR_circuit_r2" {
    source = "../../modules/vHubExRcircuit"
  name                = local.region2.ExR_circuit_name # 
  resource_group_name = module.resource_group.name     # "rg-dev-westus3"
  location            = local.region2.location
  service_provider_name = local.region2.service_provider_name
  peering_location      = local.region2.peering_location # "Silicon Valley" # "Equinix-Silicon-Valley"
  bandwidth_in_mbps     = 50

  # express_route_port_id = module.ExR_circuit_port.id
  # bandwidth_in_gbps     = 10

  allow_classic_operations = false

    tier   = "Standard"
    family = "MeteredData"

  tags = merge(
    {
      team = "me"
      environment = local.environment
    },
    local.tags
  )
}
module "ExR_circuit_peering_r2" {
  source = "../../modules/vHubExRcircuitPeering"

  peering_type                  = local.region2.peering_type
  express_route_circuit_name    = module.ExR_circuit_r2.name
  resource_group_name           = module.resource_group.name     # "rg-dev-westus3"
  shared_key                    = "ItsASecret"
  peer_asn                      = 100
  primary_peer_address_prefix   = "192.168.1.0/30"
  secondary_peer_address_prefix = "192.168.1.0/30"
  vlan_id                       = 100
  
}
module "ExR_gw_r2" {
  source = "../../modules/vHubExRgateway"
  name                = local.region2.ExR_gw_name
  resource_group_name = module.resource_group.name     # "rg-dev-westus3"
  location            = local.region2.location # "westus3"
  virtual_hub_id      = module.vhub_r2.id

  tags = merge(
    {
      team = "me"
      environment = local.environment
    },
    local.tags
  )
}

module "vnet_r2" {

  source = "../../modules/network/vnet"
  name                = "vnet-${local.environment}-${local.region2.location}"
  resource_group_name = module.resource_group.name     # "rg-dev-westus3"
  location            = local.region2.location # "westus3"
  address_space        = ["10.67.200.0/22", "10.67.204.0/22"] # each.value.address_space
  dns_servers          = []
  ddos_protection_plan = [] # [{ id = module.ddos.id, enable = true }, ]
  
  subnets = {
  plpe = {
    name                                      = "plpe"
    address_prefix                            = "10.67.200.0/24"
    service_endpoints                         = ["Microsoft.AzureActiveDirectory", "Microsoft.ContainerRegistry", "Microsoft.AzureCosmosDB", "Microsoft.EventHub", "Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.Web"]
    private_endpoint_network_policies_enabled = false
    delegation                                = []
    },
  }

  tags = merge(
    {
      team = "me"
      environment = local.environment
    },
    local.tags
  )

}

module "vhub_connection_r2" {
  source = "../../modules/vwanHubConnection"
  name = "${module.vhub_r2.name}-with-${module.vnet_r2.name}"
  remote_virtual_network_id = module.vnet_r2.id
  virtual_hub_id = module.vhub_r2.id 
}

/*
resource "azurerm_express_route_circuit_connection" "this_r1" {
  name                = "${module.ExR_circuit_r1.name}-peered-${module.ExR_circuit_r2.name}"
  peering_id          = module.ExR_circuit_peering_r1.id
  peer_peering_id     = module.ExR_circuit_peering_r2.id
  address_prefix_ipv4 = "192.169.9.0/29"
  authorization_key   = "846a1918-b7a2-4917-b43c-8c4cdaee006a"
}

resource "azurerm_express_route_circuit_connection" "this_r2" {
  name                = "${module.ExR_circuit_r2.name}-peered-${module.ExR_circuit_r1.name}"
  peering_id          = module.ExR_circuit_peering_r2.id
  peer_peering_id     = module.ExR_circuit_peering_r1.id
  address_prefix_ipv4 = "192.169.8.0/29"
  authorization_key   = "846a1918-b7a2-4917-b43c-8c4cdaee006a"
}
*/
# module "ExR_circuit_port" {
#   source = "../../modules/vHubExRcircuitPort"
#   name = "exr-port-dev-westus3"
#   resource_group_name = module.resource_group.name     # "rg-dev-westus3"
#   location            = module.resource_group.location # "westus3"
#   encapsulation = "Dot1Q"
#   peering_location      = "Equinix-Seattle-SE2"
#   bandwidth_in_mbps = 10

# }

# module "ExR_circuit_port_2" {
#   source = "../../modules/vHubExRcircuitPort"
#   name = "exr-port2-dev-westus3"
#   resource_group_name = module.resource_group.name     # "rg-dev-westus3"
#   location            = module.resource_group.location # "westus3"
#   encapsulation       = "Dot1Q"
#   peering_location    = "Equinix-Silicon-Valley" #"Equinix-Seattle-SE2"
#   bandwidth_in_mbps   = 10

# }
