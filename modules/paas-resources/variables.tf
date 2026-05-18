// variables.tf file for module pass-resources


# tenant id
variable "tenant_id" {
  type = string
}

// from hub-network module
variable "private_endpoints_subnet_id" {
}

// from module: platform
variable "rg_name" {
}
variable "rg_location" {
}

// LAW id
variable "law_id" {
}

// from hub-network module
variable "hub_vnet_id" {
}

// kv variables
variable "kv_name" {
  type = string
  default = "cnonesolutions-kv-new"
}
# Diagnostic setting for Key Vault deployed by policy!
/* variable "kv_diagnostic_setting_name" {
  type = string
  default = "kv-disgnostic-setting"
} 
*/
# Key Vault Admins group object id - referenced from module iam
variable "key_vault_admins_group_object_id" {
}
// kv dns variables
variable "kv_dns_to_hub_vnet_link" {
  type = string
  default = "key-vault-to-hub-vnet-link"
}

// Private endpoint - KV variables
variable "kv_pe_name" {
  type = string
  default = "kv-pe"
}


## For ACR
variable "acr_dns_to_hub_vnet_link" {
  type = string
  default = "acr-dns-to-hub-vnet-link"
}
variable "acr_name" {
  type = string
  default = "cnsolutionsacr"
}
variable "acr_pe_name" {
  type = string
  default = "acr-pe"
}
variable "acr_diagnostic_setting" {
  type = string
  default = "acr-diagnostic-setting"
}
# acr managers group object id - from module 'iam'
variable "acr_managers_group_object_id" {
}


# For Storage a/c
variable "sa_dns_to_hub_vnet_link" {
  type = string
  default = "sa-dns-to-hub-vnet-link"
}
variable "sa_name" {
  type = string
  default = "cnsolutionsalzstorage"
}
variable "first_container_name" {
  type = string
  default = "first-container"
}
// referenced from module - iam
variable "storage_ac_contributors_group_object_id" {
}
variable "sa_pe_name" {
  type = string
  default = "sa-pe"
}
variable "sa_diagnostic_setting" {
  type = string
  default = "sa-diagnostic-setting"
}

# For MSSQL Server +  DB
variable "mssqql_server_dns_to_hub_vnet_link" {
  type = string
  default = "mssqlserver-dns-to-hub-vnet-link"
}
variable "mssql_server_name" {
  type = string
  default = "mssql-server-cnsolns"
}
variable "mssqldb_name" {
  type = string
  default = "cnsolutionssqldb"
}
variable "mssql_server_pe_name" {
  type = string
  default = "mssql-server-pe"
}
variable "mssql_server_diagnostic_setting" {
  type = string
  default = "mssql-server-diagnostic-setting"
}
variable "sql_database_diagnostic_setting" {
  type = string
  default = "sql-database-diagnostic-setting"
}

# SQL admins group from module: iam
variable "sql_admins_group_name" {
  type = string
}
variable "sql_admins_object_id" {
  type = string
}

# 4 PaaS resources <--> Spoke Vnet link variables
variable "mssql_server_dns_to_spoke_vnet_link" {
  type = string
  default = "mssql-server-to-spoke-vnet-link"
}
variable "sa_dns_to_spoke_vnet_link" {
  type = string
  default = "sa-dns-spoke-vnet-link"
}
variable "acr_dns_to_spoke_vnet_link" {
  type = string
  default = "acr-dns-spoke-vnet-link"
}
variable "kv_dns_to_spoke_vnet_link" {
  type = string
  default = "kv-dns-to-spoke-vnet-link"
}

# spoke vnet id - referenced from module spoke-vnet
variable "spoke_vnet_id" {
}