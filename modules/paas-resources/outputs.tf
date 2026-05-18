// outputs.tf for module: PaaS resources

# ==========================================
# Key Vault Outputs
# ==========================================
output "key_vault_id" {
  description = "Resource ID of the Key Vault"
  value       = azurerm_key_vault.kv.id
}
output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.kv.name
}
output "key_vault_private_endpoint_ip" {
  description = "Private IP address of the Key Vault private endpoint"
  value       = azurerm_private_endpoint.kv_pe.private_service_connection[0].private_ip_address
}
output "key_vault_private_dns_zone_id" {
  description = "Private DNS zone ID for Key Vault"
  value       = azurerm_private_dns_zone.kv_dns.id
}


# ==========================================
# ACR Outputs
# ==========================================
output "acr_id" {
  description = "Resource ID of the Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}
output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.acr.name
}
output "acr_login_server" {
  description = "ACR login server URL"
  value       = azurerm_container_registry.acr.login_server
}
output "acr_private_endpoint_ip" {
  description = "Private IP address of the ACR private endpoint"
  value       = azurerm_private_endpoint.acr_pe.private_service_connection[0].private_ip_address
}
output "acr_private_dns_zone_id" {
  description = "Private DNS zone ID for ACR"
  value       = azurerm_private_dns_zone.acr_dns.id
}


# ==========================================
# Storage Account Outputs
# ==========================================
output "storage_account_id" {
  description = "Resource ID of the Storage Account"
  value       = azurerm_storage_account.sa.id
}
output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = azurerm_storage_account.sa.name
}
output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint for the Storage Account"
  value       = azurerm_storage_account.sa.primary_blob_endpoint
}
output "storage_account_private_endpoint_ip" {
  description = "Private IP address of the Storage Account private endpoint"
  value       = azurerm_private_endpoint.sa_pe.private_service_connection[0].private_ip_address
}
output "storage_account_private_dns_zone_id" {
  description = "Private DNS zone ID for Storage Account blob"
  value       = azurerm_private_dns_zone.sa_dns.id
}
// needed for storing VM's boot diagnostics
output "storage_account_uri" {
  value = azurerm_storage_account.sa.primary_blob_endpoint
}

# ==========================================
# SQL Server + SQL Database Outputs
# ==========================================
output "sql_server_id" {
  description = "Resource ID of the SQL Server"
  value       = azurerm_mssql_server.mssql_server.id
}
output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_mssql_server.mssql_server.name
}
output "sql_database_id" {
  description = "Resource ID of the SQL Database"
  value       = azurerm_mssql_database.mssql_database.id
}
output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = azurerm_mssql_database.mssql_database.name
}
output "sql_private_endpoint_ip" {
  description = "Private IP address of the SQL Server private endpoint"
  value       = azurerm_private_endpoint.mssql_server_pe.private_service_connection[0].private_ip_address
}
output "sql_private_dns_zone_id" {
  description = "Private DNS zone ID for SQL Server"
  value       = azurerm_private_dns_zone.mssqql_server_dns.id
}
