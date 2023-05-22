module "os" {
  source       = "./os"
  vm_os_simple = var.vm_os_simple
}

data "azurerm_resource_group" "vm" {
  name = var.resource_group_name
}

resource "random_id" "vm-sa" {
  keepers = {
    vm_hostname = var.vm_hostname
  }

  byte_length = 6
}

resource "azurerm_storage_account" "vm-sa" {
  count                    = var.boot_diagnostics ? 1 : 0
  name                     = "bootdiag${lower(random_id.vm-sa.hex)}"
  resource_group_name      = data.azurerm_resource_group.vm.name
  location                 = data.azurerm_resource_group.vm.location
  account_tier             = element(split("_", var.boot_diagnostics_sa_type), 0)
  account_replication_type = element(split("_", var.boot_diagnostics_sa_type), 1)
  tags                     = var.tags
}

resource "azurerm_windows_virtual_machine" "vm-windows" {
  count         = (var.is_windows_image || contains(tolist([var.vm_os_simple, var.vm_os_offer]), "Windows")) ? var.nb_instances : 0
  name          = "${var.vm_hostname}${format("%03d", count.index + 1)}" #-vmWindows-${format("%03d", count.index + 1)}"
  computer_name = "${var.vm_hostname}${count.index + 1}"                 # uses name if not specified
  # availability_set_id           = azurerm_availability_set.vm.id
  # platform_fault_domain = "-1" # auto assigned -1

  admin_username           = var.admin_username
  admin_password           = var.admin_password
  resource_group_name      = data.azurerm_resource_group.vm.name
  location                 = data.azurerm_resource_group.vm.location
  size                     = var.vm_size
  network_interface_ids    = [element(azurerm_network_interface.vm.*.id, count.index)]
  enable_automatic_updates = var.enable_automatic_updates
  patch_mode               = var.enable_automatic_updates == "true" ? var.patch_mode : "Manual"
  license_type             = var.license_type

  provision_vm_agent = var.provision_vm_agent

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids == [""] ? [] : var.identity_ids
  }

  source_image_id = var.vm_os_id == "" ? null : var.vm_os_id
  source_image_reference {

    publisher = var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""
    offer     = var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""
    sku       = var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""
    version   = var.vm_os_id == "" ? var.vm_os_version : ""
  }

  os_disk {
    name = "${var.vm_hostname}-osdisk-${format("%03d", count.index + 1)}"
    # create_option     = "FromImage"
    caching                   = "ReadWrite"
    storage_account_type      = var.storage_account_type
    write_accelerator_enabled = "false" # default = false

  }

  # secret {
  #   certificate = "" # (Required) One or more certificate blocks as defined above.
  #   key_vault_id = ""  # (Required) The ID of the Key Vault from which all Secrets should be
  # }

  tags = var.tags


  boot_diagnostics {
    #count = enabled     = var.boot_diagnostics
    storage_account_uri = var.boot_diagnostics ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : ""
  }

}

resource "azurerm_linux_virtual_machine" "vm-linux" {
  count         = !contains(tolist([var.vm_os_simple, var.vm_os_offer]), "Windows") && !var.is_windows_image ? var.nb_instances : 0
  name          = "${var.vm_hostname}${format("%03d", count.index + 1)}" #-vmWindows-${format("%03d", count.index + 1)}"
  computer_name = "${var.vm_hostname}${format("%03d", count.index + 1)}" # uses name if not specified
  # availability_set_id           = azurerm_availability_set.vm.id
  # platform_fault_domain = "-1" # auto assigned -1

  disable_password_authentication = var.ssh_key == "" ? "false" : "true"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  resource_group_name             = data.azurerm_resource_group.vm.name
  location                        = data.azurerm_resource_group.vm.location
  size                            = var.vm_size
  network_interface_ids           = [element(azurerm_network_interface.vm.*.id, count.index)]

  #license_type             = var.license_type

  provision_vm_agent = var.provision_vm_agent

  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids == [""] ? [] : var.identity_ids
  }

  source_image_id = var.vm_os_id == "" ? null : var.vm_os_id
  source_image_reference {

    publisher = var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""
    offer     = var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""
    sku       = var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""
    version   = var.vm_os_id == "" ? var.vm_os_version : ""
  }

  os_disk {
    name = "${var.vm_hostname}-osdisk-${format("%03d", count.index + 1)}"
    # create_option     = "FromImage"
    caching                   = "ReadWrite"
    storage_account_type      = var.storage_account_type
    write_accelerator_enabled = "false" # default = false

  }

  dynamic "admin_ssh_key" {
    for_each = var.ssh_key != "" ? [var.ssh_key] : []
    content {
      username   = var.admin_username
      public_key = file(var.ssh_key)
    }
  }

  /*
  admin_ssh_key {
    username   = var.admin_username # "/home/${var.admin_username}/.ssh/authorized_keys"
    public_key = var.ssh_key == "" ? null : file(var.ssh_key)
  }
*/
  tags = var.tags

  boot_diagnostics {
    #count = enabled     = var.boot_diagnostics
    storage_account_uri = var.boot_diagnostics ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : ""
  }

}

resource "azurerm_network_interface" "vm" {
  count                         = var.nb_instances
  name                          = "${var.vm_hostname}-nic-${format("%03d", count.index + 1)}"
  resource_group_name           = data.azurerm_resource_group.vm.name
  location                      = data.azurerm_resource_group.vm.location
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "${var.vm_hostname}-ip-${format("%03d", count.index + 1)}"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id          = length(azurerm_public_ip.vm.*.id) > 0 ? element(concat(azurerm_public_ip.vm.*.id, tolist("")), count.index) : ""
  }

  tags = var.tags
}


# resource "azurerm_availability_set" "vm" {
#   name                         = "${var.vm_hostname}-avset"
#   resource_group_name          = data.azurerm_resource_group.vm.name
#   location                     = data.azurerm_resource_group.vm.location
#   platform_fault_domain_count  = 2
#   platform_update_domain_count = 2
#   managed                      = true
#   tags                         = var.tags
# }

# resource "azurerm_public_ip" "vm" {
#   count               = var.nb_public_ip
#   name                = "${var.vm_hostname}-pip-${format("%03d", count.index + 1)}"
#   resource_group_name = data.azurerm_resource_group.vm.name
#   location            = data.azurerm_resource_group.vm.location
#   allocation_method   = var.allocation_method
#   domain_name_label   = element(var.public_ip_dns, count.index)
#   tags                = var.tags
# }

# resource "azurerm_network_security_group" "vm" {
#   name                = "${var.vm_hostname}-nsg"
#   resource_group_name = data.azurerm_resource_group.vm.name
#   location            = data.azurerm_resource_group.vm.location

#   tags = var.tags
# }

# resource "azurerm_network_security_rule" "vm" {
#   name                        = "allow_remote_${coalesce(var.remote_port, module.os.calculated_remote_port)}_in_all"
#   resource_group_name         = data.azurerm_resource_group.vm.name
#   description                 = "Allow remote protocol in from all locations"
#   priority                    = 100
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = coalesce(var.remote_port, module.os.calculated_remote_port)
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   network_security_group_name = azurerm_network_security_group.vm.name
# }

# resource "azurerm_network_interface_security_group_association" "test" {
#   count                     = var.nb_instances
#   network_interface_id      = azurerm_network_interface.vm[count.index].id
#   network_security_group_id = azurerm_network_security_group.vm.id
# }


