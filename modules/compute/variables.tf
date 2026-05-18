// variables.tf for module - compute


# referenced from module: spoke-network
variable "app_subnet_id" {
}

# referenced from module: platform
variable "rg_name" {
}
variable "rg_location" {
}

# VM NIC variables
variable "win_vm_nic_name" {
  type    = string
  default = "win-vm-nic"
}

# VM variables
variable "win_vm_name" {
  type    = string
  default = "win-vm"
}

# VM admins group object id - referenced from module: iam
variable "vm_admins_group_object_id" {
}

# referenced from module: paas-resources
# needed for storing VM's boot diagnostics
variable "storage_account_uri" {
}

# VM (resource) diagnostic setting
variable "win_vm_diagnostic_setting_name" {
  type    = string
  default = "win-vm-diagnostic-setting"
}
# from module: monitoring
variable "law_id" {
}

# =================================
# Recovery services variables
# =================================
# Recovery services vault name - from module: platform
variable "cnsolns_recovery_services_vault_name" {
}

variable "backup_policy_vm_name" {
  type    = string
  default = "vms-backup-policy"
}