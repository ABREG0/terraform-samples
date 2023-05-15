
module "resource_group" {
  source   = "../../modules/resourceGroup"
  name     = "rg-dev-westus3"
  location = "westus3"
  tags = {
    environment = "Production"
  }
}

module "vwan" {
  source              = "../../modules/vwan"
  name                = "vwan-dev-westus3"
  resource_group_name = module.resource_group.name     # "rg-dev-westus3"
  location            = module.resource_group.location # "westus3"
  type                = "Standard"
  settings = {
    disable_vpn_encryption            = true
    allow_branch_to_branch_traffic    = false
    office365_local_breakout_category = "All" # "None" # Optimize, OptimizeAndAllow, All, None 
    log_analytics_workspace_id        = null
  }
  tags = {
    environment = "Production"
  }
}
module "vhub" {
  source              = "../../modules/vHub"
  name                = "vhub-dev-westus3"
  resource_group_name = module.resource_group.name     # "rg-dev-westus3"
  location            = module.resource_group.location # "westus3"
  vwan_id             = module.vwan.id
  address_prefix      = "10.221.224.0/24"
  route = [ 
        {
            address_prefixes = ["10.221.24.0/24"]
            next_hop_ip_address = "10.20.2.10" #"vhub-dev-westus3-with-${module.vnet.name}"
        } 
    ]
  tags                = {
    environment = "Production"
    hubSaaSPreview = true

  }

}
module "vhub_ExR_circuit" {
    source = "../../modules/vHubExRcircuit"
  name = "exr-dev-westus3"
  resource_group_name = module.resource_group.name     # "rg-dev-westus3"
  location            = module.resource_group.location # "westus3"
  service_provider_name = "Equinix"
  peering_location      = "Silicon Valley"
  bandwidth_in_mbps     = 50

  allow_classic_operations = false

    tier   = "Standard"
    family = "MeteredData"


  tags = {
    environment = "Production"
  }
}
module "vhub_ExR" {
  source = "../../modules/vHubExRgateway"
  name = "exr-dev-westus3"
  resource_group_name = module.resource_group.name     # "rg-dev-westus3"
  location            = module.resource_group.location # "westus3"
  virtual_hub_id = module.vhub.id 
  tags = {
    environment = "Production"
  }
}
module "vnet" {

  source = "../../modules/network/vnet"
  name                = "vnet-dev-westus3"
  resource_group_name = module.resource_group.name     # "rg-dev-westus3"
  location            = module.resource_group.location # "westus3"
  address_space        = ["10.67.100.0/22", "10.67.104.0/22"] # each.value.address_space
  dns_servers          = []
  ddos_protection_plan = [] # [{ id = module.ddos.id, enable = true }, ]
  #   tags                       = var.tags
  tags = {
    environment = "Production"
  }
  subnets = {
  plpe = {
    name                                      = "plpe"
    address_prefix                            = "10.67.100.0/24"
    service_endpoints                         = ["Microsoft.AzureActiveDirectory", "Microsoft.ContainerRegistry", "Microsoft.AzureCosmosDB", "Microsoft.EventHub", "Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.Web"]
    private_endpoint_network_policies_enabled = false
    delegation                                = []
  },
 }
 # var.subnets

}

module "vhub_connection" {
  source = "../../modules/vwanHubConnection"
  name = "${module.vhub.name}-with-${module.vnet.name}"
  remote_virtual_network_id = module.vnet.id
  virtual_hub_id = module.vhub.id 
}