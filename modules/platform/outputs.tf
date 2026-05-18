//outputs.tf for module management-groups

//platform - parent and child mgs id
output "platform_parent_mg_id" {
  value = azurerm_management_group.platform_parent_mg.id
}
output "platform_identity_mg_id" {
  value = azurerm_management_group.identity_child_mg.id
}
output "platform_connectivity_mg_id" {
  value = azurerm_management_group.connectivity_child_mg.id
}
output "platform_sharedservices_mg_id" {
  value = azurerm_management_group.sharedservices_child_mg.id
}

//workloads - parent and child mgs id
output "workloads_parent_mg_id" {
  value = azurerm_management_group.workloads_parent_mg.id
}
output "workloads_corp_mg_id" {
  value = azurerm_management_group.corp_child_mg.id
}
output "workloads_online_mg_id" {
  value = azurerm_management_group.online_child_mg.id
}

// Resource Group - name, id and location
output "rg_name" {
  value = azurerm_resource_group.rg.name
}
output "rg_id" {
  value = azurerm_resource_group.rg.id
}
output "rg_location" {
  value = azurerm_resource_group.rg.location
}

# Recovery services vault - name and id
output "cnsolns_recovery_services_vault_name" {
  value = azurerm_recovery_services_vault.cnsolns_recovery_services_vault.name
}
output "cnsolns_recovery_services_vault_id" {
  value = azurerm_recovery_services_vault.cnsolns_recovery_services_vault.id
}
