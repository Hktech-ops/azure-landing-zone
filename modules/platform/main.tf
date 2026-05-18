// main.tf for module: platform

// associated subscription to 'workloads-corp' Management group

/* 
Tenant Root Group
│
├── Platform (Parent MG) 
│   ├── Identity
│   ├── Management
│   ├── Connectivity
│   └── SharedServices
│
└── Workloads (Parent MG)
    ├── Corp -----> associated subscription to this MG
    └── Online 
*/

/* 
provioned a Resource Group

deployed a centralized Recovery Services Vault (PaaS resource) - for backups and site recovery workloads
 - used in this project, primarily for storing VM backups
 - generally, Recovery services vault is used for sotring VM backups, Azure Files backups, SQL server on VM backups, AKS backups and so on..

*/

# -----------------------------------------------

//data source - azurerm_subscription retrieves details about the subscription Terraform is authenticated against
data "azurerm_subscription" "azure_subscription" {
}

// parent - platform mg (child of tenant root group)
// child - identity, connectivity, sharedservices mg
resource "azurerm_management_group" "platform_parent_mg" {
  display_name               = var.platform_mg_name
  parent_management_group_id = var.tenant_root_group_id //this mg is going to be the child of tenant root group!
}
resource "azurerm_management_group" "identity_child_mg" {
  display_name               = var.platform_identity_mg_name
  parent_management_group_id = azurerm_management_group.platform_parent_mg.id
}
resource "azurerm_management_group" "connectivity_child_mg" {
  display_name               = var.platform_connectivity_mg_name
  parent_management_group_id = azurerm_management_group.platform_parent_mg.id
}
resource "azurerm_management_group" "sharedservices_child_mg" {
  display_name               = var.platform_sharedservices_mg_name
  parent_management_group_id = azurerm_management_group.platform_parent_mg.id
}

// parent - workloads mg (child of tenant root group)
// child - corp & online mg
resource "azurerm_management_group" "workloads_parent_mg" {
  display_name               = var.workloads_mg_name
  parent_management_group_id = var.tenant_root_group_id //this mg is going to be the child of tenant root group!
}
resource "azurerm_management_group" "corp_child_mg" {
  display_name               = var.workloads_corp_mg_name
  parent_management_group_id = azurerm_management_group.workloads_parent_mg.id
}
resource "azurerm_management_group" "online_child_mg" {
  display_name               = var.workloads_online_mg_name
  parent_management_group_id = azurerm_management_group.workloads_parent_mg.id
}
//associated existing subscription to corp child mg
resource "azurerm_management_group_subscription_association" "sub_to_corp_mg" {
  management_group_id = azurerm_management_group.corp_child_mg.id
  subscription_id     = var.subscription_id
}

// Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location

  tags = {
    author = "HK"
    env    = "Prod"
  }
}

# Recovery Services Vault
resource "azurerm_recovery_services_vault" "cnsolns_recovery_services_vault" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name                = var.cnsolns_recovery_services_vault_name
  sku                 = "Standard"

  soft_delete_enabled = false // disabled for now
  //soft_delete_enabled = true  --> wanted to save credits!

  tags = {
    author = "HK"
    env    = "Prod"
  }
}
