// variables.tf for module: monitoring

# RG variables - sources from module: platform
variable "rg_name" {
}
variable "rg_location" {
}

# Entra id logs variables
variable "entra_id_logs_name" {
  type = string
  default = "cnsoln-entra-id-logs"
}

# Activity logs variables
variable "activity_logs_name" {
  type = string
  default = "cnsoln-activity-logs"
}


// variables for LAW
variable "law_name" {
  type = string
  default = "cnsolns-law"
}
variable "critical_action_group_name" {
  type = string
  default = "critical-action-group"
}

