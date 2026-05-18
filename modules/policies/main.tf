// main.tf for module: policies

/* 
two policy initiatives containing policy definitions

2 policy sets/initiatives: platform-guidelines & monitoring-guidelines
    platform-guidelines --> contains 'allowed locations' and 'require a (specified) tag - author and env tags
    monitoring-guidelines --> contains 'require diagnostic setting for Key Vault'
 */

/* 
require a tag policy: "Enforces existence of a tag. Does not apply to resource groups"
                      : if you want a resource to have 2 tags, then it has to be applied twice, one for each tag
  - category: General
def id: /providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99

allowed locations policy: category "General" - "Allowed locations"
definition id - /providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c
*/

/* 
monitoring policy set - "Deploy Diagnostic Settings for Key Vault to Log Analytics workspace"
  - category: Monitoring
def id - /providers/Microsoft.Authorization/policyDefinitions/bef3f64c-5290-43b7-85b0-9b254eef4c47 
*/

# ===========================
# Platform guidelines policy set - allowed locations & require tags
# ===========================

resource "azurerm_policy_set_definition" "platform_guidelines_policy_set" {
  name = var.platform_guidelines_policy_set_name
  display_name = var.platform_guidelines_policy_set_displayname
  policy_type = "Custom"

  management_group_id = var.workloads_corp_mg_id    //referenced to corp management group

  //for allowed locations policy
  parameters = jsonencode({
    listOfAllowedLocations = {
        type = "Array"
        metadata = {
            description = "Allowed Azure regions/locations for deployment"
        }
    }
  })

  ## Allowed Locations policy
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
    parameter_values = jsonencode({
        listOfAllowedLocations = {
            value = "[parameters('listOfAllowedLocations')]"
        }
    })
 }

 ## Require author tag
 policy_definition_reference {
   policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"

   parameter_values = jsonencode({
    tagName = {
        value = "author"
    }
   })
 }
 ## Require env tag
 policy_definition_reference {
   policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"

   parameter_values = jsonencode({
    tagName = {
        value = "env"
    }
   })
 }
}

# Assigned platform guideleines policy initiative to corp management group
resource "azurerm_management_group_policy_assignment" "platform_guidelines_to_corp_mg_assignment" {
  name = var.platform_guidelines_to_corp_mg_assignment
  display_name = var.platform_guidelines_to_corp_mg_assignment_displayname
  policy_definition_id = azurerm_policy_set_definition.platform_guidelines_policy_set.id
  management_group_id = var.workloads_corp_mg_id  //assigned to corp management group

  // allowed locations - has to be either of the two specified
  parameters = jsonencode({
    listOfAllowedLocations = {
        value = ["canadacentral", "canadaeast"]
    }
  }) //allowed locations is an array

  // policy set assignment identity
  identity {
    type = "SystemAssigned"
  }
  // location must be set when identity is assigned
  location = var.rg_location
}


# ===========================
# Monitoring policy set

# Deploys the diagnostic settings for Azure Key Vault to stream resource logs to a Log Analytics workspace (LAW) 
# when any Key Vault which is missing this diagnostic settings is created or updated
# definition id - /providers/Microsoft.Authorization/policyDefinitions/bef3f64c-5290-43b7-85b0-9b254eef4c47
# ===========================

resource "azurerm_policy_set_definition" "monitoring_policy_set" {
  name = var.monitoring_policy_set_name
  display_name = var.monitoring_policy_set_displayname
  policy_type = "Custom"
  
  management_group_id = var.workloads_corp_mg_id    //referenced corp management group

  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/bef3f64c-5290-43b7-85b0-9b254eef4c47"

    parameter_values = jsonencode({
      
      effect = {
        value = "DeployIfNotExists"
      }
      logAnalytics = {
        value = var.law_id
      }
      metricsEnabled = {
        value = "False"
      }
      logsEnabled = {
        value = "True"
      }
    })
  }
}

# Assign monitoring policy initiative to corp MG
resource "azurerm_management_group_policy_assignment" "monitoring_to_corp_mg_assignment" {
  name = var.monitoring_to_corp_mg_assignment
  display_name = var.monitoring_to_corp_mg_assignment_displayname
  policy_definition_id = azurerm_policy_set_definition.monitoring_policy_set.id
  management_group_id = var.workloads_corp_mg_id

  // policy set assignment id
  ## id is needed to assign RBAC roles to this policy set assignment
  identity {
    type = "SystemAssigned"
  }
  // location must be set when identity is assigned
  location = var.rg_location
}

/* 
concept: effect = DeployIfNotExists --> means it will
  - detect missing diagnostic setting on Key Valut
  - if diagnostic setting is found missing, policy will automatically assign it to Key Vault

Hence, it needs an identity and RBAC roles of 'Log Analytics Contributor' & 'Monitoring Contributor'

policy definition tries to assign these roles - BUT not a good idea to trust (role assignment may fail silentely)
BEST to ** explicitly assign those RBAC roles to policy assignment!!
*/

# RBAC roles to MG policy assignment
resource "azurerm_role_assignment" "monitoring_contributor_role_to_monitoring" {
  scope = var.subscription_id
  role_definition_name = "Monitoring Contributor"
  principal_id = azurerm_management_group_policy_assignment.monitoring_to_corp_mg_assignment.identity[0].principal_id
}
resource "azurerm_role_assignment" "log_analytics_contributor_role_to_monitoring" {
  scope = var.subscription_id
  role_definition_name = "Log Analytics Contributor"
  principal_id = azurerm_management_group_policy_assignment.monitoring_to_corp_mg_assignment.identity[0].principal_id
}
