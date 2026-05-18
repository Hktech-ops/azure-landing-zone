// main.tf for module: monitoring

/* 
structure: will have 1 centralized monitoring module that contains
    - Centralized Log Analytics Workspace (LAW) - ALL logs are sent to this LAW
       internet ingestion & internet query disabled --> logs can ONLY be accessed via private network. NO PUBLIC access
    - Activity logs (subscription level)
    - Entra ID logs (tenent level)
    - Action groups

--> Each resource will have its own diagnostic setting which will send logs to LAW by referencing its id
 */
#---------------------------------------------

# tags
locals {
  tags = {
    author = "HK"
    env    = "Prod"
  }
}

# Log Analytics Workspace (LAW) - Centralized
resource "azurerm_log_analytics_workspace" "law" {
  resource_group_name = var.rg_name
  location            = var.rg_location
  name                = var.law_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  //reservation_capacity_in_gb_per_day = 1
  daily_quota_gb = 1 // prevents runaway ingestion costs

  internet_ingestion_enabled = false // required for zero trust env
  internet_query_enabled     = false // required for zero trust env
  // both log ingestion and query cannot be done from outside the network

  tags = local.tags
}

# current Client config 
data "azurerm_client_config" "current" {
}

# ALL Entra ID (Azure AD) (tenant level) logs ---> send to central LAW
resource "azurerm_monitor_aad_diagnostic_setting" "cnsoln_entra_id_logs" {
  name                       = var.entra_id_logs_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id // central LAW

  enabled_log {
    category = "SignInLogs"
    retention_policy {
      enabled = false // as I have set retention days in LAW
    }
  }
  enabled_log {
    category = "AuditLogs"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "NonInteractiveUserSignInLogs"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "ServicePrincipalSignInLogs"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "ManagedIdentitySignInLogs"
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "ProvisioningLogs"
    retention_policy {
      enabled = false
    }
  }
}

# Activity logs (subscription level)  --> send to LAW
resource "azurerm_monitor_diagnostic_setting" "cnsoln_activity_logs" {
  name                       = var.activity_logs_name
  target_resource_id         = "/subscriptions/${data.azurerm_client_config.current.subscription_id}" // activity logs for subscription
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id                                 // send to central LAW

  enabled_log {
    category = "Administrative" //captures Resource creation, deletion, RBAC changes, policy assignments
    retention_policy {
      enabled = false // as I have set retention days in LAW
    }
  }
  enabled_log {
    category = "Policy" // policy evaluations, compliance changes, policy enforcement failures
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "Security" // threat detections, defender for cloud events, security center events
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "ServiceHealth" //service outages, regional incidents, planned maintenance
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "ResourceHealth" // resource-specific health events
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "Recommendation" // cost optimization, security, advisor recommendations 
    retention_policy {
      enabled = false
    }
  }
  enabled_log {
    category = "Alert" // alerts fired my monitor, alert rule evaluations
    retention_policy {
      enabled = false
    }
  }
}


# Action group - email trigger
resource "azurerm_monitor_action_group" "critical_action_group" {
  resource_group_name = var.rg_name
  name                = var.critical_action_group_name
  short_name          = "critical-ag"

  email_receiver {
    name                    = "send-to-owner"
    email_address           = "harsh.hk.ca@outlook.com"
    use_common_alert_schema = true
  }

  tags = local.tags
}


