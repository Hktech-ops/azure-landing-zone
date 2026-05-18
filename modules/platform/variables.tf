//variables.tf for module management-groups

//platform --> parent mg
//identity, maanagement, connectivity, sharedservices --> child mg
variable "platform_mg_name" {
    type = string
    default = "platform-mg"
}
variable "platform_identity_mg_name" {
  type = string
  default = "platform-identity-mg"
}
variable "platform_management_mg_name" {
  type = string
  default = "platform-management-mg"
}
variable "platform_connectivity_mg_name" {
  type = string
  default = "platform-connectivity-mg"
}
variable "platform_sharedservices_mg_name" {
  type = string
  default = "platform-sharedservices-mg"
}

//workloads --> parent mg
//corp and online --> child mg
variable "workloads_mg_name" {
    type = string
    default = "workloads-mg"
}
variable "workloads_corp_mg_name" {
    type = string
    default = "corp-mg"
}
variable "workloads_online_mg_name" {
    type = string
    default = "online-mg"
}

// need subscription id for associating subscription to desired MGs
variable "subscription_id" {
  type = string
}
variable "tenant_root_group_id" {
  type = string
}

// RG name and location
variable "rg_name" {
  type = string
  default = "cnsolns-azure-landing-zone"
}
variable "rg_location" {
  type = string
  default = "Canada Central"
}

# Recovery services vault
variable "cnsolns_recovery_services_vault_name" {
  type = string
  default = "cnsolns-recovery-services-vault"
}