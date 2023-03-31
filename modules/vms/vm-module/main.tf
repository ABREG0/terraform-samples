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

resource "azurerm_windows_virtual_machine_scale_set" "vm-windows" {
  count                = (var.enable_scale_set == true) && (var.is_windows_image || contains(tolist([var.vm_os_simple, var.vm_os_offer]), "Windows")) ? var.nb_instances : 0
  name                 = "${var.vm_hostname}${format("%02d", count.index + 1)}"
  computer_name_prefix = substr(var.vm_hostname, 0, 6)
  sku                  = var.vm_size
  instances            = var.vmss_nb_instances
  # platform_fault_domain = "-1" # auto assigned -1

  admin_username      = var.admin_username
  admin_password      = var.admin_password
  resource_group_name = data.azurerm_resource_group.vm.name
  location            = data.azurerm_resource_group.vm.location

  #zones                = var.enable_availability_set != true ? null : element(split(",", var.set_vm_zones), count.index)

  network_interface {
    name                          = "${var.vm_hostname}${format("%03d", count.index + 1)}-nic"
    enable_accelerated_networking = var.enable_accelerated_networking
    primary                       = true

    ip_configuration {
      name      = "${var.vm_hostname}${format("%03d", count.index + 1)}-pip"
      subnet_id = var.vnet_subnet_id

    }
  }

  enable_automatic_updates = var.enable_automatic_updates
  # patch_mode               = var.enable_automatic_updates == "true" ? var.patch_mode : "Manual"
  license_type = var.license_type

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
    caching                   = "ReadWrite"
    storage_account_type      = var.storage_account_type
    write_accelerator_enabled = "false"
    disk_size_gb              = 130
  }

  # secret {
  #   certificate = "" # (Required) One or more certificate blocks as defined above.
  #   key_vault_id = ""  # (Required) The ID of the Key Vault from which all Secrets should be
  # }

  tags = var.tags


  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : ""
  }

}

resource "azurerm_linux_virtual_machine_scale_set" "vm-linux" {
  count                = (var.enable_scale_set == true) && !contains(tolist([var.vm_os_simple, var.vm_os_offer]), "Windows") && !var.is_windows_image ? var.nb_instances : 0
  name                 = "${var.vm_hostname}${format("%02d", count.index + 1)}" #-vmWindows-${format("%03d", count.index + 1)}"
  computer_name_prefix = substr(var.vm_hostname, 0, 6)
  instances            = var.vmss_nb_instances
  sku                  = var.vm_size
  # platform_fault_domain = "-1" # auto assigned -1

  disable_password_authentication = var.ssh_key == "" ? "false" : "true"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  resource_group_name             = data.azurerm_resource_group.vm.name
  location                        = data.azurerm_resource_group.vm.location

  #zones                = var.enable_availability_set != true ? null : element(split(",", var.set_vm_zones), count.index)

  network_interface {
    name                          = "${var.vm_hostname}${format("%03d", count.index + 1)}-nic"
    enable_accelerated_networking = var.enable_accelerated_networking
    primary                       = true

    ip_configuration {
      name      = "${var.vm_hostname}${format("%03d", count.index + 1)}-pip"
      subnet_id = var.vnet_subnet_id

    }
  }

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
    caching                   = "ReadWrite"
    storage_account_type      = var.storage_account_type
    write_accelerator_enabled = "false"
    disk_size_gb              = 130
  }

  dynamic "admin_ssh_key" {
    for_each = var.ssh_key != "" ? [var.ssh_key] : []
    content {
      username   = var.admin_username
      public_key = file(var.ssh_key)
    }
  }

  tags = var.tags

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : ""
  }

}

resource "azurerm_windows_virtual_machine" "vm-windows" {
  count               = (var.enable_scale_set != true) && (var.is_windows_image || contains(tolist([var.vm_os_simple, var.vm_os_offer]), "Windows")) ? var.nb_instances : 0
  name                = "${var.vm_hostname}${format("%03d", count.index + 1)}"
  computer_name       = "${var.vm_hostname}${count.index + 1}"
  availability_set_id = var.enable_vm_zones == true ? null : var.enable_availability_set != true ? null : azurerm_availability_set.vm[0].id 

  admin_username      = var.admin_username
  admin_password      = var.admin_password
  resource_group_name = data.azurerm_resource_group.vm.name
  location            = data.azurerm_resource_group.vm.location
  size                = var.vm_size
  zone                = var.enable_vm_zones != true ? null : element(split(",", var.set_vm_zones), count.index)


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
    name                      = "${var.vm_hostname}-osdisk-${format("%03d", count.index + 1)}"
    caching                   = "ReadWrite"
    storage_account_type      = var.storage_account_type
    write_accelerator_enabled = "false"

  }

  # secret {
  #   certificate = "" # (Required) One or more certificate blocks as defined above.
  #   key_vault_id = ""  # (Required) The ID of the Key Vault from which all Secrets should be
  # }

  tags = var.tags


  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : ""
  }

}

resource "azurerm_linux_virtual_machine" "vm-linux" {
  count               = (var.enable_scale_set != true) && !contains(tolist([var.vm_os_simple, var.vm_os_offer]), "Windows") && !var.is_windows_image ? var.nb_instances : 0
  name                = "${var.vm_hostname}${format("%03d", count.index + 1)}" #-vmWindows-${format("%03d", count.index + 1)}"
  computer_name       = "${var.vm_hostname}${format("%03d", count.index + 1)}" # uses name if not specified
  availability_set_id = var.enable_vm_zones == true ? null : var.enable_availability_set != true ? null : azurerm_availability_set.vm[0].id 

  disable_password_authentication = var.ssh_key == "" ? "false" : "true"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  resource_group_name             = data.azurerm_resource_group.vm.name
  location                        = data.azurerm_resource_group.vm.location
  size                            = var.vm_size
  zone                            = var.enable_vm_zones != true ? null : element(split(",", var.set_vm_zones), count.index)

  network_interface_ids = [element(azurerm_network_interface.vm.*.id, count.index)]

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
    name                      = "${var.vm_hostname}-osdisk-${format("%03d", count.index + 1)}"
    caching                   = "ReadWrite"
    storage_account_type      = var.storage_account_type
    write_accelerator_enabled = "false"

  }

  dynamic "admin_ssh_key" {
    for_each = var.ssh_key != "" ? [var.ssh_key] : []
    content {
      username   = var.admin_username
      public_key = file(var.ssh_key)
    }
  }

  tags = var.tags

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : ""
  }

}

resource "azurerm_network_interface" "vm" {
  count                         = (var.enable_scale_set == true) ? 0 : var.nb_instances
  name                          = "${var.vm_hostname}${format("%03d", count.index + 1)}-nic"
  internal_dns_name_label       = "${var.vm_hostname}${format("%03d", count.index + 1)}"
  resource_group_name           = data.azurerm_resource_group.vm.name
  location                      = data.azurerm_resource_group.vm.location
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "${var.vm_hostname}${format("%03d", count.index + 1)}-pip"
    primary                       = "true"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic" #var.allocation_method
    #private_ip_address            = var.allocation_method == "Static" ? length(azurerm_public_ip.vm.*.ip_address) > 0 ? azurerm_public_ip.vm[count.index].ip_address : "" : null 
    public_ip_address_id = length(azurerm_public_ip.vm.*.id) > 0 ? azurerm_public_ip.vm[count.index].id : ""
  }

  tags = var.tags
}

resource "azurerm_availability_set" "vm" {
  count                        = (var.enable_availability_set != true || var.enable_vm_zones == true) || var.enable_scale_set == true ? 0 : 1
  name                         = "${var.vm_hostname}-avset"
  resource_group_name          = data.azurerm_resource_group.vm.name
  location                     = data.azurerm_resource_group.vm.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags                         = var.tags
}

resource "azurerm_public_ip" "vm" {
  count               = (var.enable_scale_set != true) && (var.deploy_pip == true) ? var.nb_instances : 0
  name                = "${var.vm_hostname}${format("%03d", count.index + 1)}-pip"
  resource_group_name = data.azurerm_resource_group.vm.name
  location            = data.azurerm_resource_group.vm.location
  sku                 = var.allocation_method == "Static" || var.enable_vm_zones == true ? "Standard" : "Basic" #
  availability_zone   = var.enable_vm_zones != true ? "No-Zone" : "Zone-Redundant"
  allocation_method   = var.allocation_method
  domain_name_label   = "${var.vm_hostname}${format("%03d", count.index + 1)}" # element(var.public_ip_dns, count.index)
  tags                = var.tags
}

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
