// outputs.tf for module: monitoring

output "law_name" {
  value = azurerm_log_analytics_workspace.law.name
}
output "law_id" {
  value = azurerm_log_analytics_workspace.law.id
}

# Entra id logs - name and id
output "entra_id_logs_name" {
  value = azurerm_monitor_aad_diagnostic_setting.cnsoln_entra_id_logs.name
}
output "entra_id_logs_id" {
  value = azurerm_monitor_aad_diagnostic_setting.cnsoln_entra_id_logs.id
}

# Activity logs - name and id
output "activity_logs_name" {
  value = azurerm_monitor_diagnostic_setting.cnsoln_activity_logs.name
}
output "activity_logs_id" {
  value = azurerm_monitor_diagnostic_setting.cnsoln_activity_logs.id
}
