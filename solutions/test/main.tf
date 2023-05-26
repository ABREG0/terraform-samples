
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
    ExR_gw_name           = "exr-gw-${local.environment}-westus3"

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

# module "rg_diag_vnet_r2" {
#   source = "../../modules/diagnosticSettings"
#   name = "${module.vnet_r2.name}-r2-diag"
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
#   resource_id = module.vnet_r2.id
# } 

module "vnet_r1" {

  source               = "../../modules/network/vnet"
  name                 = "vnet-${local.environment}-${local.region1.location}"
  resource_group_name  = module.resource_group.name # "rg-dev-westus3"
  location             = local.region1.location
  address_space        = ["10.67.100.0/22", "10.67.104.0/22"] # each.value.address_space
  dns_servers          = []
  ddos_protection_plan = [] # [{ id = module.ddos.id, enable = true }, ]

  # log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  # logs_to_enable = [] # ["none","AllMetrics","VMProtectionAlerts",]

  diagnosticSettings = {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
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

  tags = merge(
    {
      team        = "me"
      environment = local.environment
    },
    local.tags
  )

}

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
