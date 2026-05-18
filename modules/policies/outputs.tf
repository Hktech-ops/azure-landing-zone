// outputs.tf for module - policies

# ========================================
# Policy Set Definitions (Initiatives)
# ========================================
output "platform_guidelines_policy_set_id" {
  description = "ID of the Platform Guidelines policy initiative."
  value       = azurerm_policy_set_definition.platform_guidelines_policy_set.id
}
output "monitoring_policy_set_id" {
  description = "ID of the Monitoring policy initiative."
  value       = azurerm_policy_set_definition.monitoring_policy_set.id
}

# ========================================
# Policy Assignments
# ========================================
output "platform_guidelines_assignment_id" {
  description = "ID of the Platform Guidelines policy assignment at the Corp MG."
  value       = azurerm_management_group_policy_assignment.platform_guidelines_to_corp_mg_assignment.id
}
output "monitoring_assignment_id" {
  description = "ID of the Monitoring policy assignment at the Corp MG."
  value       = azurerm_management_group_policy_assignment.monitoring_to_corp_mg_assignment.id
}

# ========================================
# Policy Assignment Identities (Principal IDs)
# ========================================
output "platform_guidelines_assignment_principal_id" {
  description = "System-assigned identity principal ID for the Platform Guidelines policy assignment."
  value       = azurerm_management_group_policy_assignment.platform_guidelines_to_corp_mg_assignment.identity[0].principal_id
}
output "monitoring_assignment_principal_id" {
  description = "System-assigned identity principal ID for the Monitoring policy assignment."
  value       = azurerm_management_group_policy_assignment.monitoring_to_corp_mg_assignment.identity[0].principal_id
}

# ========================================
# RBAC Role Assignments - for monitoring policy set
# ========================================
output "monitoring_contributor_role_assignment_id" {
  description = "Role assignment ID for Monitoring Contributor on the Monitoring policy assignment identity."
  value       = azurerm_role_assignment.monitoring_contributor_role_to_monitoring.id
}
output "log_analytics_contributor_role_assignment_id" {
  description = "Role assignment ID for Log Analytics Contributor on the Monitoring policy assignment identity."
  value       = azurerm_role_assignment.log_analytics_contributor_role_to_monitoring.id
}
