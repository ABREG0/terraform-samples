provider "azurerm" {

  features {}
}
# Declare an aliased provider block using your preferred configuration.
# This will be used for the deployment of all "Connectivity resources" to the specified `subscription_id`.

provider "azurerm" {
  alias           = "connectivity"
  subscription_id = "d200e3b2-c0dc-4076-bd30-4ccccf05ffeb"
  features {}
}
