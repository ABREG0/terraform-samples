
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

module "resource_group" {
  source   = "../../modules/resourceGroup"
  name     = local.vwan.resource_group_name # "rg-dev-westus3"
  location = local.vwan.location            # "westus3"

  tags = merge(
    {
      team        = "me"
      environment = local.environment
    },
    local.tags
  )
}
resource "azurerm_log_analytics_workspace" "this" {
  name                       = "law-${local.environment}-westus3"
  resource_group_name        = module.resource_group.name     # "rg-dev-westus3"
  location                   = module.resource_group.location # "westus3"
  sku                        = "PerGB2018"
  retention_in_days          = 30
  internet_ingestion_enabled = true
  internet_query_enabled     = true

}
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
      team        = "me"
      environment = local.environment
    },
    local.tags
  )
}
module "vhub_r1" {
  source              = "../../modules/vHub"
  name                = local.region1.name         # 
  resource_group_name = module.resource_group.name # "rg-dev-westus3"
  location            = local.region1.location     # "westus3"
  vwan_id             = module.vwan.id
  address_prefix      = local.region1.address_prefix
  # route = [ 
  #       {
  #           address_prefixes = ["10.21.20.0/24"]
  #           next_hop_ip_address = "10.20.2.10" #"vhub-dev-westus3-with-${module.vnet.name}"
  #       },
  #       {
  #           address_prefixes = ["10.21.24.0/24"]
  #           next_hop_ip_address = "10.20.3.10" #"vhub-dev-westus3-with-${module.vnet.name}"
  #       } 
  #   ]

  tags = merge(
    {
      team        = "me"
      environment = local.environment
    },
    local.tags
  )
}
module "ExR_gw_r1" {
  source              = "../../modules/vHubExRgateway"
  name                = local.region1.ExR_gw_name
  resource_group_name = module.resource_group.name # "rg-dev-westus3"
  location            = local.region1.location
  virtual_hub_id      = module.vhub_r1.id

  tags = merge(
    {
      team        = "me"
      environment = local.environment
    },
    local.tags
  )
}
module "palo_vnet_r1" {

  source               = "../../modules/network/vnet"
  name                 = "vnet-palo-${local.environment}-${local.region1.location}"
  resource_group_name  = module.resource_group.name # "rg-dev-westus3"
  location             = local.region1.location
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
  virtual_hub_id            = module.vhub_r1.id
  
  # routing = [
  #   {
  #     # associated_route_table_id = module.vhub_default_route_table_r1_routes.id
  #   }
  # ]
}
module "vhub_default_route_table_r1_routes" {
  source            = "../../modules/vhubRTroutes"
  name              = "default-rt-r1-${local.environment}-${local.region1.location}"
  route_table_id    = module.vhub_r1.default_rt_id
  destinations_type = "CIDR" # "CIDR" , "ResourceId" , "Service"
  destinations      = ["10.0.0.0/24"]
  next_hop_type     = "ResourceId"
  next_hop          = module.palo_to_hub_conn_r1.id
}
