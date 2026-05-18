// variables.tf for module: policies

# =============================
# Platform guidelines policy set
# =============================
variable "platform_guidelines_policy_set_name" {
  type    = string
  default = "platform-guidelines-policy-set"
}
variable "platform_guidelines_policy_set_displayname" {
  type    = string
  default = "platform-guidelines-policy-set"
}

// Policy assignment variables
// assignment name - must NOT exceed 24 characters
variable "platform_guidelines_to_corp_mg_assignment" {
  type    = string
  default = "guidelines-to-corp-mg"
}
variable "platform_guidelines_to_corp_mg_assignment_displayname" {
  type    = string
  default = "guidelines-to-corp-mg"
}

# from module: platform
variable "workloads_corp_mg_id" {
}

# =============================
# Monitoring policy set
# =============================
variable "monitoring_policy_set_name" {
  type    = string
  default = "monitoring-policy-set"
}
variable "monitoring_policy_set_displayname" {
  type    = string
  default = "monitoring-policy-set"
}
// Centralized Log Analytics Workspace - referenced from monitoring module
variable "law_id" {
}

// Policy assignment variables
// assignment name - must NOT exceed 24 characters
variable "monitoring_to_corp_mg_assignment" {
  type    = string
  default = "monitoring-to-corp-mg"
}
variable "monitoring_to_corp_mg_assignment_displayname" {
  type    = string
  default = "monitoring-to-corp-mg"
}

// for role assignment to policy set
variable "subscription_id" {
}
// referenced from module: platform
variable "rg_location" {
}