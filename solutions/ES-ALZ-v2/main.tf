
locals {
  environment = "prod"

  vwan = {
    vwan_id = null

    vawan_name          = "vwan-${local.environment}-westus3"
    resource_group_name = "rg-vwan"
    location            = "westus3"
    type                = "Standard"
  }

  region1 = {
    name                  = "vhub-r1-${local.environment}-westus3"
    location              = "westus3"
    address_prefix        = "10.21.224.0/24"
    ExR_circuit_name      = "exr-r1-${local.environment}-westus3"
    service_provider_name = "Equinix"
    peering_location      = "Silicon Valley" # "Equinix-Silicon-Valley"
    peering_type          = "AzurePrivatePeering"
    ExR_gw_name           = "exr-gw-r1-${local.environment}-westus3"

  }

  tags = {
    team        = "local-me"
    environment = "local-${local.environment}"
  }
}

data "azurerm_resource_group" "this" {
  name     = local.vwan.resource_group_name 
}
/*
  locals {
    logging = flatten([
      for value in [module.vhub_r1, module.palo_vnet_r1, ] :
      {
        name = value.name,
        id   = value.id
      }
    ])
    # user_policy_pairs = flatten([
    #   for policy, users in [module.vhub_r1, module.palo_vnet_r1,] : [
    #     for user in users: {
    #       policy = policy
    #       user   = user
    #     }
    #   ]
    # ])
  }
*/
data "azurerm_virtual_hub" "this"  {
  name                = local.region1.name 
  resource_group_name = data.azurerm_resource_group.this.name
}

module "palo_vnet_r1" {

  source               = "../../modules/network/vnet"
  name                 = "vnet-palo-${local.environment}-${local.region1.location}"
  resource_group_name  = data.azurerm_resource_group.this.name
  location             = data.azurerm_resource_group.this.local
  address_space        = ["10.67.100.0/22"] 
  dns_servers          = []
  ddos_protection_plan = [] 

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
      team        = "me"
      environment = local.environment
    },
    local.tags
  )

}
module "palo_to_hub_conn_r1" {
  source                    = "../../modules/vwanHubConnection"
  name                      = "conn-${module.palo_vnet_r1.name}"
  remote_virtual_network_id = module.palo_vnet_r1.id
  virtual_hub_id            = data.azurerm_virtual_hub.this.id
  
  # routing = [
  #   {
  #     # associated_route_table_id = data.azurerm_virtual_hub.this.default_route_table_id
  #   }
  # ]
}

module "AppZone0_vnet_r1" {

  source               = "../../modules/network/vnet"
  name                 = "vnet-AppZone0-${local.environment}-${local.region1.location}"
  resource_group_name  = data.azurerm_resource_group.this.name
  location             = data.azurerm_resource_group.this.local
  address_space        = ["10.67.108.0/22"]
  dns_servers          = []
  ddos_protection_plan = [] 

  subnets = {
    plpe = {
      name                                      = "plpe"
      address_prefix                            = "10.67.108.0/24"
      service_endpoints                         = ["Microsoft.AzureActiveDirectory", "Microsoft.ContainerRegistry", "Microsoft.AzureCosmosDB", "Microsoft.EventHub", "Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.Web"]
      private_endpoint_network_policies_enabled = false
      delegation                                = []
    },
  }

  tags = merge(
    {
      team        = "me"
      environment = local.environment
    },
    local.tags
  )

}
data "azurerm_virtual_hub_route_table" "AppZone0" {
  name                = "rt-AppZone0-r1-${local.environment}-${local.region1.location}"
  resource_group_name       = data.azurerm_resource_group.this.name
  virtual_hub_name          = data.azurerm_virtual_hub.this.name
}
data "azurerm_virtual_network" "AppZone0" {
  name = module.AppZone0_vnet_r1.name
  resource_group_name = data.azurerm_resource_group.this.name
}
module "AppZone0_to_hub_conn_r1" {
  source                    = "../../modules/vwanHubConnection"
  name                      = "conn-${data.azurerm_virtual_network.AppZone0.name}"
  remote_virtual_network_id = data.azurerm_virtual_network.AppZone0.id
  virtual_hub_id            = data.azurerm_virtual_hub.this.id
  
  # routing = [
  #   {
  #     associated_route_table_id = module.vhub_default_route_table_r1_routes.id
  #   }
  # ]
}

module "AppZone0_route_table_r1_routes" {
  source            = "../../modules/vhubRTroutes"
  name              = "routes-AppZone0-r1-${local.environment}-${local.region1.location}"
  route_table_id    = data.azurerm_virtual_hub_route_table.AppZone0.id
  destinations_type = "CIDR" # "CIDR" , "ResourceId" , "Service"
  destinations      = ["10.10.0.0/16"]
  next_hop_type     = "ResourceId"
  next_hop          = module.AppZone0_to_hub_conn_r1.id
}

module "AppZone1_vnet_r1" {

  source               = "../../modules/network/vnet"
  name                 = "vnet-AppZone1-${local.environment}-${local.region1.location}"
  resource_group_name  = data.azurerm_resource_group.this.name
  location             = data.azurerm_resource_group.this.local
  address_space        = ["10.67.112.0/22"] 
  dns_servers          = []
  ddos_protection_plan = [] 

  subnets = {
    plpe = {
      name                                      = "plpe"
      address_prefix                            = "10.67.112.0/24"
      service_endpoints                         = ["Microsoft.AzureActiveDirectory", "Microsoft.ContainerRegistry", "Microsoft.AzureCosmosDB", "Microsoft.EventHub", "Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.Web"]
      private_endpoint_network_policies_enabled = false
      delegation                                = []
    },
  }

  tags = merge(
    {
      team        = "me"
      environment = local.environment
    },
    local.tags
  )

}
data "azurerm_virtual_hub_route_table" "AzppZone1" {
  name                = "rt-AzppZone1-r1-${local.environment}-${local.region1.location}"
  resource_group_name       = data.azurerm_resource_group.this.name
  virtual_hub_name          = data.azurerm_virtual_hub.this.name
}
data "azurerm_virtual_network" "AppZone1" {
  name = module.AppZone1_vnet_r1.name
  resource_group_name = data.azurerm_resource_group.this.name
}
module "AppZone1_to_hub_conn_r1" {
  source                    = "../../modules/vwanHubConnection"
  name                      = "conn-${module.AppZone1_vnet_r1.name}"
  remote_virtual_network_id = data.azurerm_virtual_network.AppZone1.id
  virtual_hub_id            = data.azurerm_virtual_hub.this.id
  
  # routing = [
  #   {
  #     associated_route_table_id = data.azurerm_virtual_hub_route_table.AzppZone1.id
  #   }
  # ]
}
module "AppZone1_route_table_r1_routes" {
  source            = "../../modules/vhubRTroutes"
  name              = "routes-AppZone1-r1-${local.environment}-${local.region1.location}"
  route_table_id    = data.azurerm_virtual_hub_route_table.AzppZone1.id
  destinations_type = "CIDR" # "CIDR" , "ResourceId" , "Service"
  destinations      = ["10.11.0.0/16"]
  next_hop_type     = "ResourceId"
  next_hop          = module.AppZone1_to_hub_conn_r1.id
}

/*

# Only resource we are going to create to connect ExR GW to Circuit.
# ExR_id and Peering ID provided by customer
resource "azurerm_express_route_connection" "this_r1" {
  name                             = "example-r1"
  express_route_gateway_id         = module.ExR_gw_r1.id
  express_route_circuit_peering_id = module.ExR_circuit_peering_r1.id
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
*/

locals {
  region2 = {
    name                  = "vhub-r2-${local.environment}-westus"
    location              = "westus"
    address_prefix        = "10.221.224.0/24"
    ExR_circuit_name      = "exr-r2-${local.environment}-westus"
    service_provider_name = "Equinix"
    peering_location      = "Seattle" # "Equinix-Silicon-Valley"
    peering_type          = "AzurePrivatePeering"
    ExR_gw_name           = "exr-gw-r2-${local.environment}-westus"
  }

}