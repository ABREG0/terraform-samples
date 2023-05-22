

resource "azurerm_virtual_network" "this" {

  name                = var.name
  location            = var.location
  address_space       = var.address_space
  resource_group_name = var.resource_group_name
  dns_servers         = var.dns_servers
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      # tags, 
      tags,
    ]
  }

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan
    content {
      id     = lookup(ddos_protection_plan.value, "id", null)
      enable = lookup(ddos_protection_plan.value, "enable", false)
    }
  }

}

resource "azurerm_subnet" "subnet" {
  # depends_on = [azurerm_virtual_network.this]

  for_each                                  = var.subnets
  name                                      = each.key
  virtual_network_name                      = azurerm_virtual_network.this.name
  address_prefixes                          = [each.value.address_prefix]
  resource_group_name                       = azurerm_virtual_network.this.resource_group_name
  service_endpoints                         = each.value.service_endpoints
  private_endpoint_network_policies_enabled = each.value.private_endpoint_network_policies_enabled

  dynamic "delegation" {
    for_each = coalesce(lookup(each.value, "delegation"), [])
    content {
      name = lookup(delegation.value, "name", null)
      dynamic "service_delegation" {
        for_each = coalesce(lookup(delegation.value, "service_delegation"), [])
        content {
          name    = lookup(service_delegation.value, "name", null)
          actions = lookup(service_delegation.value, "actions", null)
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      service_endpoint_policy_ids,
    ]
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.subnet["plpe"].id
  network_security_group_id = module.nsg_default.id
}

module "nsg_default" {
  source              = "../nsg"
  name                = "${var.name}-default-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
