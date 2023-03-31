#cabrego 2021
#az_provider.tf - construct AzureRM provider initilization of backend
#

# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used

terraform {
  backend "azurerm" {
    # resource_group_name  = "tfstate-rg"
    # storage_account_name = "tfstate-sa"
    # container_name       = "tfstate-cont"
    # key                  = "1.tfstate"
  }
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=2.71.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  # More information on the authentication methods supported by
  # the AzureRM Provider can be found here:
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

  # subscription_id = "..."
  # client_id       = "..."
  # client_secret   = "..."
  # tenant_id       = "..."
}

data "azurerm_client_config" "current" {}

locals {
  name     = "cabr-dha-mlp-test"
  location = "west us 2"
  sa_name  = "dha0mlp0ml0"
  # resourcegroup_state_exists = length(values(data.terraform_remote_state.arm.outputs)) == 0 ? false : true
}

# Create a resource group
resource "azurerm_resource_group" "this" {
  name     = "production-resources"
  location = "West US 2"
}

# Create a virtual network in the production-resources resource group
resource "azurerm_virtual_network" "this" {
  name                = "production-network"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = ["10.0.0.0/16"]
}
