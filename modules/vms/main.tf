
data "azurerm_virtual_network" "vnet-win" {
  name                = var.windows-vm.vnet.name                # var.vnet_name
  resource_group_name = var.windows-vm.vnet.resource_group_name # var.vnet_resource_group_name
}

data "azurerm_subnet" "subnet-win" {
  name                 = var.windows-vm.vnet.subnet_name
  resource_group_name  = data.azurerm_virtual_network.vnet-win.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet-win.name
}

resource "azurerm_resource_group" "win-rg" {
  count    = var.windows-vm.resource_group.exists == false ? 1 : 0
  name     = var.windows-vm.resource_group.name
  location = data.azurerm_virtual_network.vnet-win.location
}

data "azurerm_key_vault" "this" {
  name                = "santana-uw-kv-d"
  resource_group_name = "Management"
}

data "azurerm_key_vault_certificate" "this" {
  name         = "vm-nix-cert"
  key_vault_id = data.azurerm_key_vault.this.id
}

data "azurerm_virtual_network" "vnet-nix" {
  name                = var.linux-vm.vnet.name                  # var.vnet_name
  resource_group_name = var.windows-vm.vnet.resource_group_name # var.vnet_resource_group_name
}

data "azurerm_subnet" "subnet-nix" {
  name                 = var.linux-vm.vnet.subnet_name
  resource_group_name  = data.azurerm_virtual_network.vnet-nix.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet-nix.name
}

resource "azurerm_resource_group" "nix-rg" {
  count    = var.linux-vm.resource_group.exists == false ? 1 : 0
  name     = var.linux-vm.resource_group.name
  location = data.azurerm_virtual_network.vnet-nix.location
}

# TODO 
## data disks
## load balancer for availability sets and VMs

module "windowsservers" {
  source                  = "./vm-module"
  enable_vm_zones         = var.windows-vm.enable_vm_zones
  enable_availability_set = var.windows-vm.enable_availability_set
  enable_scale_set        = var.windows-vm.enable_scale_set
  nb_instances            = 2
  resource_group_name     = azurerm_resource_group.win-rg[0].name
  is_windows_image        = var.windows-vm.is_windows_image
  vm_hostname             = var.windows-vm.hostname // line can be removed if only one VM module per resource group
  vm_size                 = var.windows-vm.size
  admin_password          = var.windows-vm.admin_password
  vm_os_simple            = var.windows-vm.os_simple
  public_ip_dns           = var.windows-vm.public_ip_dns
  vnet_subnet_id          = data.azurerm_subnet.subnet-win.id
  deploy_pip              = var.windows-vm.deploy_pip
  allocation_method       = var.windows-vm.allocation_method #"Dynamic" # or Static
  depends_on              = [azurerm_resource_group.win-rg]
}

module "linuxservers" {
  source                  = "./vm-module"
  enable_vm_zones         = var.linux-vm.enable_vm_zones
  enable_availability_set = var.linux-vm.enable_availability_set
  enable_scale_set        = var.linux-vm.enable_scale_set
  nb_instances            = 2
  vm_hostname             = var.linux-vm.hostname
  vm_size                 = var.linux-vm.size
  resource_group_name     = azurerm_resource_group.nix-rg[0].name
  vm_os_simple            = var.linux-vm.os_simple
  admin_password          = var.linux-vm.admin_password
  public_ip_dns           = var.linux-vm.public_ip_dns
  vnet_subnet_id          = data.azurerm_subnet.subnet-nix.id
  deploy_pip              = var.linux-vm.deploy_pip
  allocation_method       = var.linux-vm.allocation_method #"Dynamic" # or Static
  ssh_key                 = var.linux-vm.ssh_key             #data.azurerm_key_vault_certificate.this.certificate_data_base64 #

  depends_on = [azurerm_resource_group.nix-rg]
}

/*
resource "azurerm_virtual_machine_extension" "PowerShell" {

  count                = length(module.windowsservers.vm_ids)
  name                 = "testps2"
  virtual_machine_id   = module.windowsservers.vm_ids[count.index]
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {   
        "fileUris": [
          "https://raw.githubusercontent.com/ABREG0/ps-examples/master/testing/test2.ps1",
          "https://raw.githubusercontent.com/ABREG0/ps-examples/7ca5944c63b7563c160ef472ebacdff288fecb5c/testing/test3.ps1"
        ],
        "commandToExecute": "powershell -ExecutionPolicy unrestricted -NoProfile -NonInteractive -file ./test2.ps1"
    }
SETTINGS

  tags = {
    environment = "Production"
  }
  lifecycle {
    ignore_changes = [
      settings,
      protected_settings,
    ]
  }
  depends_on = [
    module.windowsservers
  ]
}

resource "azurerm_virtual_machine_extension" "sh-test2" {

  count                = length(module.windowsservers.vm_ids)
  name                 = "test3"
  virtual_machine_id   = module.linuxservers.vm_ids[count.index]
  publisher            = "Microsoft.Azure.Extensions" #Linux
  type                 = "CustomScript"
  type_handler_version = "2.1"
  settings             = <<SETTINGS
    {   
        "fileUris": ["https://raw.githubusercontent.com/ABREG0/ps-examples/master/testing/test2.sh"],
        "commandToExecute": "bash test2.sh"

    }
SETTINGS

  tags = {
    environment = "Production"
  }
  lifecycle {
    ignore_changes = [
      settings,
      protected_settings,
    ]
  }
  depends_on = [
    module.linuxservers,
    # azurerm_virtual_machine_extension.test2
  ]
}

# "managedIdentity" : {}  #use to set MSI to access scripts in fileUris


resource "azurerm_virtual_machine_extension" "domainJoin" {
    depends_on = [
    module.windowsservers
  ]
  
  count                = length(module.windowsservers.vm_ids)
  name                       = "adds-domainJoin"
  # name                       = "${var.vm_hostname}-${count.index + 1}-domainJoin"
  virtual_machine_id         = module.winserv.vm_ids[count.index]
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  #"/subscriptions/<subscription id>/resourceGroups/WIN10/providers/Microsoft.Compute/virtualMachines/win10addsman" #"${azurerm_virtual_machine.main.*.name[count.index]}"

lifecycle {
    ignore_changes = [
      settings,
      protected_settings,
    ]
  }

  settings = <<SETTINGS
    {
        "Name": "${var.domain_name}",
        "User": "${var.domain_adminuser}",
        "OUPath": "${var.domain_ou}",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
         "Password": "${var.domain_password}"
  }
PROTECTED_SETTINGS

}

tags = {
    environment = "Production"
  }
}








resource "azurerm_virtual_machine_extension" "winxt" {
  depends_on = [ module.windowsservers ]
  count = length(module.windowsservers.vm_hosts)
  name                 = "testps1"
  virtual_machine_id   = module.windowsservers.vm_ids[count.index]
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.9"
  auto_upgrade_minor_version = true
  
  # publisher            = "Microsoft.Azure.Extensions" #Linux
  # type                 = "CustomScript"
  
  settings = jsonencode(
    {   
      "fileUris": ["https://raw.githubusercontent.com/ABREG0/ps-examples/2bc5ba3d9e57a49b22819d5ca55f2d8dbe488e44/testing/ext-test.ps1"],
        
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File ./test.ps1"

  lifecycle {
    ignore_changes = [
      settings,
      protected_settings,
    ]
  }
  settings = <<SETTINGS
    {
        "fileUris": ["https://github.com/ABREG0/ps-examples/blob/d04bb980ec4e92df39e10b84aa8e91c2465d47fb/testing/ext-test.ps1"],
        
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file ./ext-test.ps1"
    }
SETTINGS

}
# fileUris - permanent link from gihub must be coplied
#"commandToExecute": "powershell -ExecutionPolicy Unrestricted -c {dir}"
# "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File ./wvd-agent.ps1 ${module.hostpool.wvd.registration_info[0].token}" #script with parameters 




# resource "azurerm_virtual_machine_extension" "PowerShell" {
#   count                      = 2
#   name                       = "helperScript2"
#   virtual_machine_id         = module.winserv.vm_ids[count.index]
#   publisher                  = "Microsoft.Compute"
#   type                       = "CustomScriptExtension"
#   type_handler_version       = "1.9"
#   auto_upgrade_minor_version = true

#   depends_on = [
#     module.winserv,
#   ]

#   lifecycle {
#     ignore_changes = [
#       settings,
#       protected_settings,
#     ]
#   }
#   settings = <<SETTINGS
#     {
#         "fileUris": ["https://[storageAccountName].blob.core.windows.net/wvdscripts/wvd-agent.ps1?sp=r&st=2021-06-09T21:51:52Z&se=2051-06-10T05:51:52Z&spr=https&sv=2020-02-10&sr=b&sig=9oWeFrSPg%"],
        
#         "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File ./wvd-agent.ps1 ${module.hostpool.wvd.registration_info[0].token}"
#     }
#     SETTINGS
# }
# # "rename c:\\azuredata\\customdata.bin customdata.ps1 && powershell -file c:\\azuredata\\customdata.ps1"
# # ["https://github.com/ABREG0/az-sentinel/blob/20fc1c3b2eaf74b8b4505dde4771cfa88c881ebb/templateRules/helper.ps1"],
# #["https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"],
# #https://github.com/ABREG0/az-sentinel/blob/20fc1c3b2eaf74b8b4505dde4771cfa88c881ebb/templateRules/helper.ps1

*/
