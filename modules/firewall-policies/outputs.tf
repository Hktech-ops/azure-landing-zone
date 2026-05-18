// outputs.tf for module: firewall policies

output "hub_firewall_policy_id" {
  description = "The ID of the Azure Firewall Policy."
  value       = azurerm_firewall_policy.hub_firewall_policy.id
}

output "firewall_policy_name" {
  description = "The name of the Azure Firewall Policy."
  value       = azurerm_firewall_policy.hub_firewall_policy.name
}

output "dnat_rule_collection_group_id" {
  description = "The ID of the DNAT rule collection group."
  value       = azurerm_firewall_policy_rule_collection_group.dnat_rules_cg.id
}

output "network_rule_collection_group_id" {
  description = "The ID of the Network rule collection group."
  value       = azurerm_firewall_policy_rule_collection_group.network_rules_cg.id
}

output "application_rule_collection_group_id" {
  description = "The ID of the Application rule collection group."
  value       = azurerm_firewall_policy_rule_collection_group.app_rules_cg.id
}


