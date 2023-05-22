provider "azurerm" {

  features {}
}
# Declare an aliased provider block using your preferred configuration.
# This will be used for the deployment of all "Connectivity resources" to the specified `subscription_id`.

provider "azurerm" {
  alias           = "connectivity"
  subscription_id = "00000000-0000-0000-0000-000000000000"
  features {}
}

# # Declare a standard provider block using your preferred configuration.
# # This will be used for the deployment of all "Management resources" to the specified `subscription_id`.

# provider "azurerm" {
#   alias           = "management"
#   subscription_id = "11111111-1111-1111-1111-111111111111"
#   features {}
# }

# Map each module provider to their corresponding `azurerm` provider using the providers input object

# module "caf-enterprise-scale" {
#   source  = "Azure/caf-enterprise-scale/azurerm"
#   version = "<version>" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

#   providers = {
#     azurerm              = azurerm
#     azurerm.connectivity = azurerm.connectivity
#     azurerm.management   = azurerm.management
#   }

#   # insert the required input variables here
# }
