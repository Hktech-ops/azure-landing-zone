// main.tf for module: paas-resources

/* 
4 PaaS resources deployed in this module
a. Key Valut
b. ACR
c. Storage a/c
d. SQL Database

All 4 PaaS resources have a private DNS zone + private endpoint  --> no public access
All 4 PaaS resources have diagnostic setting enabled ---> telemetry is sent to central LAW
list diagnostic-settings available for the resource (CLI): az monitor diagnostic-settings categories list --resource "resource_id"


All 4 PaaS resources have:
  - NO public access
  - RBAC enabled
  - private DNS zone + private endpoint (stored in private endpoints subnet in hub vnet)

Linked all 4 PaaS resouces' private DNS zones to spoke Vnet
 - why? I wanted to allow compute resource deployed in spoke vnet to be able to access PaaS resources

*/
#-----------------------------------------------------------------

# for tags
locals {
  common_tags = {
    author = "HK"
    env    = "Prod"
  }
}


# =====================================================
# Key Vault 
# with RBAC enabled, public access disabled
# private DNS zone, diagnostic setting
# =====================================================
resource "azurerm_key_vault" "kv" {
  resource_group_name = var.rg_name
  location            = var.rg_location
  name                = var.kv_name
  tenant_id           = var.tenant_id //initialized in tfvars
  //tenant_id = data.azurerm_client_config.current_client_details.tenant_id // referenced from the data block above
  sku_name = "standard"

  public_network_access_enabled = false // set true for test --> you can later change to false to disable public access
  enable_rbac_authorization     = true
  soft_delete_retention_days    = 7    // retain deleted records for * days --> recycle bin
  purge_protection_enabled      = true // you can't delete records from recycle bin accidentally

  /* Network acls - not needed if you disable public access + have private endpoints  
 network_acls {
    default_action = "Deny" // remove this line if you disable public network access
    bypass = "AzureServices"
  } */

  tags = local.common_tags
}

# Key vault admin role assignment to Group - Key Vault Admins - referenced from module 'iam'
resource "azurerm_role_assignment" "kv_admin_role_assignment" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.key_vault_admins_group_object_id //object id of Key Vault Admins group
}

# private dns zone for key vualt
resource "azurerm_private_dns_zone" "kv_dns" {
  resource_group_name = var.rg_name
  name                = "privatelink.vaultcore.azure.net" // key vault dns name has to be this one!

  tags = local.common_tags
}

# link key vault private dns zone to hub-vnet
# Private DNS zones must be linked to the VNet that contains the Private Endpoint’s NIC
resource "azurerm_private_dns_zone_virtual_network_link" "kv_dns_to_hub_vnet_link" {
  resource_group_name   = var.rg_name
  name                  = var.kv_dns_to_hub_vnet_link
  private_dns_zone_name = azurerm_private_dns_zone.kv_dns.name
  virtual_network_id    = var.hub_vnet_id // hub vnet id

  tags = local.common_tags
}

# private endpoint to Key vault
resource "azurerm_private_endpoint" "kv_pe" {
  resource_group_name = var.rg_name
  location            = var.rg_location
  name                = var.kv_pe_name
  subnet_id           = var.private_endpoints_subnet_id // PE subnet - referenced from module: hub-network

  // connection to key vault
  private_service_connection {
    name                           = "kv-connection"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"] // subresources_names is mandatory for KV and name has to be this one
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "kv-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv_dns.id]
  }
  tags = local.common_tags
}

# Policy already deployed Diagnostic setting!!
# Diagnostic setting for Key Vault
/* resource "azurerm_monitor_diagnostic_setting" "kv_diagnostic_setting" {
  name = var.kv_diagnostic_setting_name
  target_resource_id = azurerm_key_vault.kv.id
  log_analytics_workspace_id = var.law_id

  enabled_log {
    category = "AuditEvent" // tracks all access attempts (success + failures)
  }
} */

# ================================
# ACR
# ACR Push + Pull role assigned to 'acr managers group'
# ACR PR + diagnostic setting
# ================================
// ACR
resource "azurerm_container_registry" "acr" {
  resource_group_name = var.rg_name
  location            = var.rg_location
  name                = var.acr_name
  sku                 = "Premium" //Standard
  admin_enabled       = false     //admin replaced with RBAC roles - ACRPush and ACRPull

  public_network_access_enabled = false // for now - change it later

  tags = local.common_tags

  identity {
    type = "SystemAssigned"
  }
}
# ACR Push and pull role assignment - to acr managers groups
resource "azurerm_role_assignment" "acr_push_role_assignment" {
  role_definition_name = "ACRPush"
  scope                = azurerm_container_registry.acr.id
  principal_id         = var.acr_managers_group_object_id //acr managers group
}
resource "azurerm_role_assignment" "acr_pull_role_assignment" {
  role_definition_name = "ACRPull"
  scope                = azurerm_container_registry.acr.id
  principal_id         = var.acr_managers_group_object_id //acr managers group
}


// private dns zone + link to hub Vnet for ACR
resource "azurerm_private_dns_zone" "acr_dns" {
  resource_group_name = var.rg_name
  name                = "privatelink.azurecr.io" // private dns name for ACR - has to be this one

  tags = local.common_tags
}
resource "azurerm_private_dns_zone_virtual_network_link" "acr_dns_to_hub_vnet_link" {
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.acr_dns.name
  name                  = var.acr_dns_to_hub_vnet_link
  virtual_network_id    = var.hub_vnet_id // hub vnet id

  tags = local.common_tags
}

# ACR private endpoint
resource "azurerm_private_endpoint" "acr_pe" {
  resource_group_name = var.rg_name
  location            = var.rg_location
  name                = var.acr_pe_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "acr-connection"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"] // subresources_names is mandatory for acr and name has to be this one
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "acr-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.acr_dns.id]
  }

  tags = local.common_tags
}

# Diagnostic setting for ACR
resource "azurerm_monitor_diagnostic_setting" "acr_diagnostic_setting" {
  name                       = var.acr_diagnostic_setting
  target_resource_id         = azurerm_container_registry.acr.id
  log_analytics_workspace_id = var.law_id // referenced from module - monitoring

  enabled_log {
    category = "ContainerRegistryLoginEvents" // logs ALL login attempts
  }
  enabled_log {
    category = "ContainerRegistryRepositoryEvents" // logg push, pull, delete of container images 
  }

  /* enabled_metric {
    category = "AllMetrics" // ALL registry performance metrics - latency, throughput
  } */
}


# ================================
# Storage Account
# Storage blob data contributor role assigned to storage a/c contributor group
# private DNS zone + hub vent link + PE for storage account
# Diagnostic setting for SA + blob
# ================================
# Storage Account
resource "azurerm_storage_account" "sa" {
  resource_group_name      = var.rg_name
  location                 = var.rg_location
  name                     = var.sa_name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled   = false //change it to false later on
  allow_nested_items_to_be_public = false // does NOT allow objects with in SA (containers, blobs, files to be made public even when SA is not publically accessible)
  shared_access_key_enabled       = true
  //allow_shared_key_access = true
  //shared_access_key_enabled = false

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}
// Adding a blob container
resource "azurerm_storage_container" "first-container" {
  storage_account_name  = azurerm_storage_account.sa.name
  name                  = var.first_container_name
  container_access_type = "private"
}

# Storage Data Blob Contributor RBAC role to storage a/c contributors group
resource "azurerm_role_assignment" "storage_blob_data_contributor_role" {
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.sa.id
  principal_id         = var.storage_ac_contributors_group_object_id //from module 'iam'
}

# private DNS zone + hub vnet link for Storage Account
resource "azurerm_private_dns_zone" "sa_dns" {
  resource_group_name = var.rg_name
  name                = "privatelink.blob.core.windows.net" // has to be this name for storae account

  tags = local.common_tags
}
resource "azurerm_private_dns_zone_virtual_network_link" "sa_dns_to_hub_vnet_link" {
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.sa_dns.name
  name                  = var.sa_dns_to_hub_vnet_link
  virtual_network_id    = var.hub_vnet_id // hub vnet - referenced from module: hub-network

  tags = local.common_tags
}

# SA private endpoint
resource "azurerm_private_endpoint" "sa_pe" {
  resource_group_name = var.rg_name
  location            = var.rg_location
  name                = var.sa_pe_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "sa-connection"
    subresource_names              = ["blob"]
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "sa-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sa_dns.id]
  }

  tags = local.common_tags
}

# Storage A/C Diagnostic setting - metrics for Storage account
resource "azurerm_monitor_diagnostic_setting" "sa_diagnostic_setting" {
  name                       = var.sa_diagnostic_setting
  target_resource_id         = azurerm_storage_account.sa.id
  log_analytics_workspace_id = var.law_id //referenced from module - monitoring

  metric {
    category = "Capacity"
    enabled  = true
  }
  metric {
    category = "Transaction"
    enabled  = true
  }
}

###  Storage A/C Diagnostics are splitted into - blob, files, tables and qeue disgnostic settings

# Storage blob Diagnostic Setting
resource "azurerm_monitor_diagnostic_setting" "sa_blob_diagnostic_setting" {
  name                       = "${var.sa_name}-blob-diagnostic-setting"
  target_resource_id         = "${azurerm_storage_account.sa.id}/blobServices/default"
  log_analytics_workspace_id = var.law_id //referenced from module - monitoring

  enabled_log {
    category = "StorageRead"
  }
  enabled_log {
    category = "StorageWrite"
  }
  enabled_log {
    category = "StorageDelete"
  }
  metric {
    category = "Transaction"
    enabled  = true
  }
}


# ================================
# SQL Server + Database
# AD Authentication only, SQL Server Contributor role to sql-admins group
# Disgnostic setting for both SQL Server + Database
# Private DNS zone for SQL Server + Hub Vnet link
# ================================
# MSSQL server
resource "azurerm_mssql_server" "mssql_server" {
  resource_group_name = var.rg_name
  location            = var.rg_location
  name                = var.mssql_server_name
  version             = "12.0"
  minimum_tls_version = "1.2"

  public_network_access_enabled = false // disble it later on

  //Control plane role - SQL Server roles............ Data plane role (contorls access inside the database) are different and are assigned via SQL queries
  // who can manage SQL server in Azure
  azuread_administrator {
    azuread_authentication_only = true                      // authentication via Entra ID only
    login_username              = var.sql_admins_group_name // SQL Server login user name
    object_id                   = var.sql_admins_object_id  // admin user - sql admins group
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# Diagnostic setting for SQL Server
resource "azurerm_monitor_diagnostic_setting" "mssql_server_diagnostic_setting" {
  name                       = var.mssql_server_diagnostic_setting
  target_resource_id         = azurerm_mssql_server.mssql_server.id
  log_analytics_workspace_id = var.law_id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# SQL Database
resource "azurerm_mssql_database" "mssql_database" {
  name      = var.mssqldb_name
  server_id = azurerm_mssql_server.mssql_server.id
  sku_name  = "Basic"
  //zone_redundant = false

  tags = local.common_tags
}

# Diagnostic setting for SQL Database
resource "azurerm_monitor_diagnostic_setting" "sql_database_diagnostic_setting" {
  name                       = var.sql_database_diagnostic_setting
  target_resource_id         = azurerm_mssql_database.mssql_database.id
  log_analytics_workspace_id = var.law_id //referenced from module: monitoring

  # for SQL Database Audit logs
  enabled_log {
    category = "SQLSecurityAuditEvents"
  }
  # SQLInsights → High‑level performance insights
  enabled_log { category = "SQLInsights" }

  # AutomaticTuning → Logs tuning recommendations/actions
  enabled_log { category = "AutomaticTuning" }

  # QueryStoreWaitStatistics → Wait events
  enabled_log { category = "QueryStoreWaitStatistics" }

  # Errors → SQL engine errors
  enabled_log { category = "Errors" }

  # DatabaseWaitStatistics → Wait metrics
  enabled_log { category = "DatabaseWaitStatistics" }

  # Timeouts → Query timeouts
  enabled_log { category = "Timeouts" }

  # Blocks → Blocking chains
  enabled_log { category = "Blocks" }

  # Deadlocks → Deadlock graphs
  enabled_log { category = "Deadlocks" }

  /* # AllMetrics → CPU, IO, storage, DTU metrics
  enabled_metric { category = "AllMetrics" } */

  metric {
    category = "Basic"
    enabled  = true
  }
}

# SQL Server contributor role assignment to sql-admins groups
resource "azurerm_role_assignment" "sql_admins_group_role_assignment" {
  role_definition_name = "SQL Server Contributor"
  scope                = azurerm_mssql_server.mssql_server.id
  principal_id         = var.sql_admins_object_id //sql admins group
}

# SQL Server Private DNS zone + hub Vnet link
resource "azurerm_private_dns_zone" "mssqql_server_dns" {
  resource_group_name = var.rg_name
  name                = "privatelink.database.windows.net" // has to be this name for sql database

  tags = local.common_tags
}
resource "azurerm_private_dns_zone_virtual_network_link" "mssqql_server_dns_to_hub_vnet_link" {
  resource_group_name   = var.rg_name
  name                  = var.mssqql_server_dns_to_hub_vnet_link
  private_dns_zone_name = azurerm_private_dns_zone.mssqql_server_dns.name
  virtual_network_id    = var.hub_vnet_id // hub vnet id

  tags = local.common_tags
}

# SQL Server private endpoint
resource "azurerm_private_endpoint" "mssql_server_pe" {
  resource_group_name = var.rg_name
  location            = var.rg_location
  name                = var.mssql_server_pe_name
  subnet_id           = var.private_endpoints_subnet_id // referenced from hub-network

  private_service_connection {
    name                           = "mssql-server-connection"
    subresource_names              = ["sqlServer"]
    private_connection_resource_id = azurerm_mssql_server.mssql_server.id
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "mssql-server-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.mssqql_server_dns.id]
  }

  tags = local.common_tags
}


# ======================================
# Link all 4 PaaS resources' private DNS zones to spoke Vnet
# Reason - allow compute resources / workloads deployed in spoke to be able to access PaaS resources
# ======================================

# MSSQL private DNS zone  <--> Spoke vnet link
resource "azurerm_private_dns_zone_virtual_network_link" "mssql_server_dns_to_spoke_vnet_link" {
  resource_group_name   = var.rg_name
  name                  = var.mssql_server_dns_to_spoke_vnet_link
  private_dns_zone_name = azurerm_private_dns_zone.mssqql_server_dns.name //mssql server private DNS zone
  virtual_network_id    = var.spoke_vnet_id                               // spoke vnet id

  tags = local.common_tags
}

# Storage A/C private DNS zone  <--> Spoke vnet link
resource "azurerm_private_dns_zone_virtual_network_link" "sa_dns_to_spoke_vnet_link" {
  resource_group_name   = var.rg_name
  name                  = var.sa_dns_to_spoke_vnet_link
  private_dns_zone_name = azurerm_private_dns_zone.sa_dns.name // SA private DNS zone
  virtual_network_id    = var.spoke_vnet_id                    // spoke vnet id

  tags = local.common_tags
}

# ACR private DNS zone  <--> Spoke vnet link
resource "azurerm_private_dns_zone_virtual_network_link" "acr_dns_to_spoke_vnet_link" {
  resource_group_name   = var.rg_name
  name                  = var.acr_dns_to_spoke_vnet_link
  private_dns_zone_name = azurerm_private_dns_zone.acr_dns.name //acr private DNS zone
  virtual_network_id    = var.spoke_vnet_id                     // spoke vnet id

  tags = local.common_tags
}

# Key Vault private DNS zone  <--> Spoke vnet link
resource "azurerm_private_dns_zone_virtual_network_link" "kv_dns_to_spoke_vnet_link" {
  resource_group_name   = var.rg_name
  name                  = var.kv_dns_to_spoke_vnet_link
  private_dns_zone_name = azurerm_private_dns_zone.kv_dns.name // KV private DNS zone
  virtual_network_id    = var.spoke_vnet_id                    // spoke vnet id

  tags = local.common_tags
}