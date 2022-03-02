# output "vnet" {
#   value = data.azurerm_virtual_network.vnet.name
# }

# output "subnet" {
#   value = data.azurerm_subnet.subnet.name
# }

output "network_interface_ids" {
  description = "ids of the vm nics provisoned."
  value       = module.windowsservers.network_interface_ids
}

output "windows_vms" {
  description = "Virtual machine ids created."
  value = [
    { for vm in module.windowsservers.all_vms :
      vm.name => "IP:${vm.private_ip_address}, PIP:${vm.public_ip_address}}"
    },
    # { for vm in module.windowsservers.all_vms :
    #   vm.name => var.linux-vm.enable_availability_set != true ? null : "availabilitySet_id:${vm.availability_set_id}"
    # },
    # { for vm in module.win-vmss.all_vms :
    #   vm.name => "scaleSet_id:${vm.virtual_machine_scale_set_id}"
    # },
    { for vm in module.windowsservers.all_vms :
      vm.name => "IP:${vm.private_ip_address}, PIP:${vm.public_ip_address}}"
    },
    { for vm in module.linuxservers.all_vms :
      vm.name => "nic:${vm.network_interface_ids[0]}"
    }
  ] 
}

output "linux_vms" {
  description = "Virtual machine ids created."
  value =  [
    { for vm in module.linuxservers.all_vms :
      vm.name => "IP:${vm.private_ip_address}, PIP:${vm.public_ip_address}}"
    },
    # { for vm in module.linuxservers.all_vms :
    #   vm.name => var.linux-vm.enable_availability_set != true ? null : "availabilitySet_id:${vm.availability_set_id}"
    # },
    # { for vm in module.nix-vmss.all_vms :
    #   vm.name => "scaleSet_id:${vm.virtual_machine_scale_set_id}"
    # },
    { for vm in module.linuxservers.all_vms :
      vm.name => "IP:${vm.private_ip_address}, PIP:${vm.public_ip_address}}"
    }
  ] 
}

output "vm_msi" {
  description = "Virtual machine ids created."
  value = var.windows-vm.enable_scale_set != true ? [
    { for vm in module.windowsservers.all_vms :
      vm.name => "MSI:${vm.identity[0].principal_id}, type:${vm.identity[0].type}"
    },
    { for vm in module.linuxservers.all_vms :
      vm.name => "MSI:${vm.identity[0].principal_id}, type:${vm.identity[0].type}"
    }
  ] : null
}

output "vm_ids" {
  description = "Virtual machine ids created."
  value = var.windows-vm.enable_scale_set != true ? [
    { for vm in module.windowsservers.all_vms :
      vm.name => "id:${vm.id}}"
    },
    { for vm in module.linuxservers.all_vms :
      vm.name => "id:${vm.id}}"
    }
  ] : null
}

output "public_ip_dns_name" {
  description = "fqdn to connect to the first vm provisioned."
  value = var.windows-vm.enable_scale_set != true ? [
    [for dns in module.windowsservers.public_ip_dns_name :
      dns
    ],
    [for dns in module.linuxservers.public_ip_dns_name :
      dns
    ]
  ] : null
}

output "All_hosts_name" {
  description = "Virtual machine ids created."
  value = [
    [for host in module.windowsservers.vm_hosts_name :
      host
    ],
    [for host in module.linuxservers.vm_hosts_name :
      host
    ]

  ]
}

/*
output "all_vms" {
  description = "Virtual machine ids created."
  value       = concat(module.windowsservers.all_vms, module.linuxservers.all_vms)
  sensitive = true
}

output "win_vm_hosts" {
  value = module.windowsservers.vm_hosts
}

output "win_vm_ids" {
  value = module.windowsservers.vm_ids
}

output "nix_vm_hosts" {
  value = module.linuxservers.vm_hosts
}

output "nix_vm_ids" {
  value = module.linuxservers.vm_ids
}

output "vm_ext_PowerShell" {
  value     = azurerm_virtual_machine_extension.PowerShell
  sensitive = true
}

output "public_ip_dns_name" {
  description = "fqdn to connect to the first vm provisioned."
  value       = module.windowsservers.public_ip_dns_name
}


output "network_interface_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = module.windowsservers.network_interface_private_ip
}

output "public_ip_id" {
  description = "id of the public ip address provisoned."
  value       = module.windowsservers.public_ip_id
}

output "public_ip_address" {
  description = "The actual ip address allocated for the resource."
  value       = module.windowsservers.public_ip_address
}
*/