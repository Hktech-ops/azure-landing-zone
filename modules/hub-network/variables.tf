// variables.tf for module: hub-network


#############################################
# Resource Group (from module: platform)
#############################################
variable "rg_name" {
  description = "Name of the resource group for hub network resources."
  type        = string
}
variable "rg_location" {
  description = "Azure region where hub network resources will be deployed."
  type        = string
}


#############################################
# Hub Virtual Network & Subnets
#############################################
variable "hub_vnet_name" {
  description = "Name of the Hub Virtual Network."
  type        = string
  default     = "hub-vnet"
}
# Subnet names
variable "firewall_subnet_name" {
  description = "Name of the Azure Firewall subnet."
  type        = string
  default     = "AzureFirewallSubnet"
}
variable "bastion_subnet_name" {
  description = "Name of the Azure Bastion subnet."
  type        = string
  default     = "AzureBastionSubnet"
}
variable "gateway_subnet_name" {
  description = "Name of the Gateway subnet."
  type        = string
  default     = "GatewaySubnet"
}
variable "private_endpoints_subnet_name" {
  description = "Name of the subnet hosting private endpoints."
  type        = string
  default     = "private-endpoints-subnet"
}

#############################################
# Log Analytics Workspace (from module: monitoring)
#############################################
variable "law_id" {
  description = "Resource ID of the Log Analytics Workspace."
  type        = string
}


#############################################
# Firewall Configuration
#############################################
variable "hub_firewall_public_ip_name" {
  description = "Name of the public IP resource for the Hub Firewall."
  type        = string
  default     = "firewall-public-ip"
}
variable "hub_firewall_name" {
  description = "Name of the Hub Firewall instance."
  type        = string
  default     = "hub-firewall"
}
variable "firewall_diagnostic_setting" {
  description = "Name of the diagnostic settings for the Hub Firewall."
  type        = string
  default     = "firewall-diagnostic-setting"
}
variable "hub_firewall_policy_id" {
  description = "Resource ID of the Firewall Policy applied to the Hub Firewall."
  type        = string
}


#############################################
# Azure Monitor Private Link Scope (AMPLS)
#############################################
variable "ampls_name" {
  description = "Name of the Azure Monitor Private Link Scope."
  type        = string
  default     = "ampls-monitoring"
}
variable "monitor_pe_name" {
  description = "Name of the Azure Monitor Private Endpoint."
  type        = string
  default     = "monitor-pe"
}
variable "ampls_hub_link_to_law_name" {
  description = "Name of the AMPLS link connecting to the Log Analytics Workspace."
  type        = string
  default     = "ampls-hub-link-to-law"
}


#############################################
# Bastion Host Configuration
#############################################
variable "bastion_host_name" {
  description = "Name of the Azure Bastion host."
  type        = string
  default     = "cnsolns-bastion-host"
}
variable "bastion_host_public_ip_name" {
  description = "Name of the public IP resource for the Bastion host."
  type        = string
  default     = "bastion-host-public-ip"
}
