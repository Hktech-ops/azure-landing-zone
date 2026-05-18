// variables.tf for module: spoke-network

# variables.tf for module spoke-network

// RG name and location - referenced from module hub-network
variable "rg_name" {
}
variable "rg_location" {
}

// hub vnet name and id - referenced from module hub-network
variable "hub_vnet_name" {
}
variable "hub_vnet_id" {
}
variable "hub_vnet_address_space" {
}

//from hub-network
variable "hub_firewall_private_ip_address" {
}



# Spoke Vnet and Subnet names 
variable "spoke_vnet_name" {
  type = string
  default = "spoke-vnet"
}
variable "app_subnet_name" {
  type = string
  default = "app-subnet"
}
variable "database_subnet_name" {
  type = string
  default = "database-subnet"
}
variable "workload_subnet_name" {
  type = string
  default = "workload-subnet"
}


# common route table for ALL subnets - for routing outbound traffic via Firewall
variable "spoke_subnets_rt" {
  type = string
  default = "spoke-subnets-rt"
}
variable "spoke_subnets_rt_diagnostic_setting" {
  type = string
  default = "spoke-subnets-rt-diagnostic-setting"
}

# LAW id --> sourced from module: monitoring
variable "law_id" {
}

# nsg for each app + database + workload subnets
variable "app_nsg_name" {
  type = string
  default = "app-nsg"
}
// app-database NSG diagnostic setting
variable "app_nsg_diagnostic_setting_name" {
  type = string
  default = "app-nsg-diagnostic-setting"
}

# Database NSG
variable "database_nsg_name" {
  type = string
  default = "database-nsg"
}
variable "database_nsg_diagnostic_setting_name" {
  type = string
  default = "database-nsg-diagnostic-setting"
}

# Worklaod NSG
variable "workload_nsg_name" {
  type = string
  default = "workload-nsg"
}
// workload NSG diagnostic setting
variable "workload_nsg_diagnostic_setting_name" {
  type = string
  default = "workload-nsg-diagnostic-setting"
}

# Link Monitor, oms, ods Private DNS zones to Spoke Vnet
# DNS zones for monitor, oms, ods are referenced from module hub-network
variable "monitor_private_dns_zone_name" {
}
variable "oms_private_dns_zone_name" {
}
variable "ods_private_dns_zone_name" {
}

# Private DNS zones to Spoke vnet link
variable "monitor_private_dns_zone_to_spokevnet_link_name" {
  type = string
  default = "monitor-private-dns-zone-to-spokevnet-link"
}
variable "oms_private_dns_zone_to_spokevnet_link_name" {
  type = string
  default = "oms-private-dns-zone-to-spokevnet-link"
}
variable "ods_private_dns_zone_to_spokevnet_link_name" {
  type = string
  default = "ods-private-dns-zone-to-spokevnet-link"
}