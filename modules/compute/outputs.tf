// outputs.tf for module: compute

output "win_vm_id" {
  description = "The resource ID of the Windows VM"
  value       = azurerm_windows_virtual_machine.win_vm.id
}

output "win_vm_name" {
  description = "The name of the Windows VM"
  value       = azurerm_windows_virtual_machine.win_vm.name
}

output "win_vm_private_ip" {
  description = "The private IP address of the VM NIC"
  value       = azurerm_network_interface.win_vm_nic.ip_configuration[0].private_ip_address
}

output "win_vm_nic_id" {
  description = "The NIC ID for the Windows VM"
  value       = azurerm_network_interface.win_vm_nic.id
}

output "win_vm_identity_principal_id" {
  description = "The system-assigned managed identity principal ID"
  value       = azurerm_windows_virtual_machine.win_vm.identity[0].principal_id
}

output "win_vm_backup_policy_id" {
  description = "The backup policy ID applied to the VM"
  value       = azurerm_backup_policy_vm.backup_policy_vm.id
}

output "win_vm_backup_protection_id" {
  description = "The protected VM backup binding ID"
  value       = azurerm_backup_protected_vm.backup_policy_vm_binding.id
}
