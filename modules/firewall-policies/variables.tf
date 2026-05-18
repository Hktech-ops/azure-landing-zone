// variables.tf for module: firewall policies


# RG name and location - referenced from module: platform
variable "rg_name" {
}
variable "rg_location" {
}

# Firewall's public IP + private IP - referenced from module: hub-network
variable "hub_firewall_public_ip_address" {
}
variable "hub_firewall_private_ip_address" {
}


# app subnet CIDR - from module: spoke-network
variable "app_subnet_cidr" {
}

//VM private IP - from module: compute
variable "win_vm_private_ip" {
}


# Firewall policy variables
variable "hub_firewall_policy_name" {
  type    = string
  default = "hub-firewall-policy"
}

# Dnat rule collection group name
variable "dnat_rules_cg_name" {
  type    = string
  default = "dnat-rules-cg"
}

# Network rules collection group name
variable "network_rules_cg_name" {
  type    = string
  default = "network-rules-cg"
}

# Application rules collection group nmae
variable "app_rules_cg_name" {
  type    = string
  default = "application-rules-cg"
}