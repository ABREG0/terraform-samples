output "vm_ids" {
  description = "Virtual machine ids created."
  value       = concat(azurerm_windows_virtual_machine.vm-windows.*.id, azurerm_linux_virtual_machine.vm-linux.*.id)
}

output "vm_hosts" {
  description = "Virtual machine ids created."
  value       = concat(azurerm_windows_virtual_machine.vm-windows.*.name, azurerm_linux_virtual_machine.vm-linux.*.name)
}


output "network_interface_ids" {
  description = "ids of the vm nics provisoned."
  value       = azurerm_network_interface.vm.*.id
}

output "network_interface_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = azurerm_network_interface.vm.*.private_ip_address
}
