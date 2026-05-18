// outputs.tf for module: access-management

#############################################
# SQL Admins Group Outputs
#############################################
output "sql_admins_group_id" {
  description = "The ID of the SQL Admins Azure AD group."
  value       = azuread_group.sql_admins_group.id
}
output "sql_admins_group_name" {
  description = "The display name of the SQL Admins Azure AD group."
  value       = azuread_group.sql_admins_group.display_name
}
output "sql_admins_group_object_id" {
  description = "The object ID of the SQL Admins Azure AD group."
  value       = azuread_group.sql_admins_group.object_id
}
output "sql_admins_group_members_ids" {
  description = "Object IDs of members assigned to the SQL Admins group."
  value       = azuread_group_member.sql_admins_group_members.member_object_id
}


#############################################
# Key Vault Admins Group Outputs
#############################################
output "key_vault_admins_group_object_id" {
  description = "The object ID of the Key Vault Admins Azure AD group."
  value       = azuread_group.key_vault_admins_group.object_id
}


#############################################
# ACR Managers Group Outputs
#############################################
output "acr_managers_group_object_id" {
  description = "The object ID of the ACR Managers Azure AD group."
  value       = azuread_group.acr_managers_group.object_id
}


#############################################
# Storage Account Contributors Group Outputs
#############################################
output "storage_ac_contributors_group_object_id" {
  description = "The object ID of the Storage Account Contributors Azure AD group."
  value       = azuread_group.storage_ac_contributors.object_id
}


#############################################
# VM Admins Group Outputs
#############################################
output "vm_admins_group_object_id" {
  description = "The object ID of the VM Admins Azure AD group."
  value       = azuread_group.vm_admins_group.object_id
}
