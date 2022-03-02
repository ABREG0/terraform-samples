output "vm_ids" {
  description = "Virtual machine ids created."
  value       = concat(azurerm_windows_virtual_machine.vm-windows.*.id, azurerm_linux_virtual_machine.vm-linux.*.id, azurerm_windows_virtual_machine_scale_set.vm-windows.*.id, azurerm_linux_virtual_machine_scale_set.vm-linux.*.id)
}

output "vm_hosts_name" {
  description = "Virtual machine ids created."
  value       = concat(azurerm_windows_virtual_machine.vm-windows.*.name, azurerm_linux_virtual_machine.vm-linux.*.name, azurerm_windows_virtual_machine_scale_set.vm-windows.*.name, azurerm_linux_virtual_machine_scale_set.vm-linux.*.name)
}


output "all_vms" {
  description = "Virtual machine ids created."
  value       = concat(azurerm_windows_virtual_machine.vm-windows, azurerm_linux_virtual_machine.vm-linux)
}

output "vmss" {
  description = "Virtual machine ids created."
  value       = concat(azurerm_windows_virtual_machine_scale_set.vm-windows, azurerm_linux_virtual_machine_scale_set.vm-linux)
}


output "network_interface_ids" {
  description = "ids of the vm nics provisoned."
  value       = azurerm_network_interface.vm.*.id
}

output "network_interface_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = azurerm_network_interface.vm.*.private_ip_address
}

output "public_ip_dns_name" {
  description = "fqdn to connect to the first vm provisioned."
  value       = azurerm_public_ip.vm.*.fqdn
}

/* 
output "public_ip_id" {
  description = "id of the public ip address provisoned."
  value       = azurerm_public_ip.vm.*.id
}

output "public_ip_address" {
  description = "The actual ip address allocated for the resource."
  value       = azurerm_public_ip.vm.*.ip_address
}

output "availability_set_id" {
  description = "id of the availability set where the vms are provisioned."
  value       = azurerm_availability_set.vm.id
}


output "network_security_group_id" {
  description = "id of the security group provisioned"
  value       = azurerm_network_security_group.vm.id
}

output "network_security_group_name" {
  description = "name of the security group provisioned"
  value       = azurerm_network_security_group.vm.name
}
 */