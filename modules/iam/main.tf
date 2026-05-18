// main.tf for module: iam - identity and access management
// there are two files in this module - main and outputs.tf

/* 
This module provides centralized user management for Entra ID users
Specifically, it controls definining users (data sources), creating groups and adding members to groups
*/

/* Goal 
 - import users (data sources) that are already present in Entra ID
 - create groups
 - add members to groups
*/

# Define users - already present in Entra ID. Remember, you need to add to entra id first
data "azuread_user" "purchase_chemical" {
  user_principal_name = "purchase.chemical1_gmail.com#EXT#@purchasechemical1gmail.onmicrosoft.com"
}
data "azuread_user" "harsh" {
  user_principal_name = "harsh@purchasechemical1gmail.onmicrosoft.com"
  //object_id = "33311aed-dabc-43a6-b1a0-c0de26b96adf"
  // no need to hard code object id - can be referreced directly
}

# Create a group - SQL admins group
resource "azuread_group" "sql_admins_group" {
  display_name     = "sql-admins"
  security_enabled = true
}

/* 
# client config - no longer needed after referenced member object id dynamically
data "azurerm_client_config" "current_client_details" {
}
*/

# Add users to sql_admin group
resource "azuread_group_member" "sql_admins_group_members" {
  group_object_id  = azuread_group.sql_admins_group.object_id
  member_object_id = data.azuread_user.harsh.object_id
  //member_object_id = data.azurerm_client_config.current_client_details.object_id //object id of the currently signed in user
}

# Group - Key Vault Admins
resource "azuread_group" "key_vault_admins_group" {
  display_name     = "key-vaults-admins"
  security_enabled = true
}
# Add users to Key Vault Admins group
resource "azuread_group_member" "key_vault_admins_group_members" {
  group_object_id  = azuread_group.key_vault_admins_group.object_id
  member_object_id = data.azuread_user.harsh.object_id
}


# Group - ACR Managers
# RBAC role assigned - ACRPush and ACRPull
resource "azuread_group" "acr_managers_group" {
  display_name     = "acr-managers"
  security_enabled = true
}
# Add users to ACR Managers group
resource "azuread_group_member" "acr_managers_group_members" {
  group_object_id  = azuread_group.acr_managers_group.object_id
  member_object_id = data.azuread_user.harsh.object_id
}

# Group - Storage account contributors
# RBAC role assigned - Storage Account Contributor
resource "azuread_group" "storage_ac_contributors" {
  display_name     = "storage-ac-contributors"
  security_enabled = true
}
# Add users to Storage account contributors group
resource "azuread_group_member" "storage_ac_contributors_group_members" {
  group_object_id  = azuread_group.storage_ac_contributors.object_id
  member_object_id = data.azuread_user.harsh.object_id
}

# Group - VM admins
# RBAC role assigned - Virtual Machine Administrator
resource "azuread_group" "vm_admins_group" {
  display_name     = "vm-admins"
  security_enabled = true
}
# Add users to VM admins group
resource "azuread_group_member" "vm_admins_group_members" {
  group_object_id  = azuread_group.vm_admins_group.object_id
  member_object_id = data.azuread_user.harsh.object_id
}
