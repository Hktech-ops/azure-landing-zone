# hub-network module - outputs.tf

# ============================
# Hub VNet
# ============================
output "hub_vnet_id" {
  description = "ID of the Hub Virtual Network"
  value       = azurerm_virtual_network.hub_vnet.id
}
output "hub_vnet_name" {
  description = "Name of the Hub Virtual Network"
  value       = azurerm_virtual_network.hub_vnet.name
}
output "hub_vnet_address_space" {
  description = "Address space of the Hub Virtual Network"
  value       = azurerm_virtual_network.hub_vnet.address_space
}

# ============================
# Subnets
# ============================
output "firewall_subnet_id" {
  description = "ID of the Firewall subnet"
  value       = azurerm_subnet.firewall_subnet.id
}
output "bastion_subnet_id" {
  description = "ID of the Bastion subnet"
  value       = azurerm_subnet.bastion_subnet.id
}
output "bastion_subnet_cidr" {
  description = "CIDR of AzureBastionSubnet"
  value = azurerm_subnet.bastion_subnet.address_prefixes
}
output "gateway_subnet_id" {
  description = "ID of the Gateway subnet"
  value       = azurerm_subnet.gateway_subnet.id
}
output "private_endpoints_subnet_id" {
  description = "ID of the Private Endpoints subnet"
  value       = azurerm_subnet.private_endpoints_subnet.id
}
output "private_endpoints_subnet_cidr" {
  description = "private endpoints subnet CIDR"
  value = azurerm_subnet.private_endpoints_subnet.address_prefixes[0]
}

# ============================
# AMPLS (Azure Monitor Private Link Scope)
# ============================
output "ampls_id" {
  description = "ID of the Azure Monitor Private Link Scope (AMPLS)"
  value       = azurerm_monitor_private_link_scope.ampls_hub.id
}
output "ampls_name" {
  description = "Name of the Azure Monitor Private Link Scope (AMPLS)"
  value       = azurerm_monitor_private_link_scope.ampls_hub.name
}
output "ampls_hub_link_to_law_id" {
  description = "ID of the AMPLS link to Log Analytics Workspace"
  value       = azurerm_monitor_private_link_scoped_service.ampls_hub_link_to_law.id
}

# ============================
# Private Endpoint (Azure Monitor)
# ============================
output "monitor_private_endpoint_id" {
  description = "ID of the Private Endpoint for Azure Monitor"
  value       = azurerm_private_endpoint.monitor_pe.id
}
output "monitor_private_endpoint_ip" {
  description = "Private IP assigned to the Azure Monitor Private Endpoint"
  value       = azurerm_private_endpoint.monitor_pe.private_service_connection[0].private_ip_address
}

## ============================
# Private DNS Zones (names and IDs)
# ============================
output "monitor_private_dns_zone_id" {
  description = "ID of the Monitor Private DNS Zone"
  value       = azurerm_private_dns_zone.monitor_private_dns_zone.id
}
output "monitor_private_dns_zone_name" {
  description = "Name of the Monitor Private DNS Zone"
  value       = azurerm_private_dns_zone.monitor_private_dns_zone.name
}

output "oms_private_dns_zone_id" {
  description = "ID of the OMS (ingestion) Private DNS Zone"
  value       = azurerm_private_dns_zone.oms_private_dns_zone.id
}
output "oms_private_dns_zone_name" {
  description = "Name of the OMS (ingestion) Private DNS Zone"
  value       = azurerm_private_dns_zone.oms_private_dns_zone.name
}

output "ods_private_dns_zone_id" {
  description = "ID of the ODS (query) Private DNS Zone"
  value       = azurerm_private_dns_zone.ods_private_dns_zone.id
}
output "ods_private_dns_zone_name" {
  description = "Name of the ODS (query) Private DNS Zone"
  value       = azurerm_private_dns_zone.ods_private_dns_zone.name
}


# ============================
# Firewall
# ============================
output "hub_firewall_public_ip_id" {
  description = "ID of the Firewall Public IP"
  value       = azurerm_public_ip.hub_firewall_public_ip.id
}
output "hub_firewall_public_ip_address" {
  description = "Firewall's public IP address"
  value = azurerm_public_ip.hub_firewall_public_ip.ip_address
}
output "hub_firewall_id" {
  description = "ID of the Azure Firewall"
  value       = azurerm_firewall.hub_firewall.id
}
output "hub_firewall_private_ip_address" {
  description = "Private IP of the Azure Firewall"
  value       = azurerm_firewall.hub_firewall.ip_configuration[0].private_ip_address
}

# ============================
# Firewall Diagnostic Settings
# ============================

output "firewall_diagnostic_setting_id" {
  description = "ID of the Firewall Diagnostic Setting"
  value       = azurerm_monitor_diagnostic_setting.firewall_diagnostic_setting.id
}



# ============================
# Bastion host
# ============================
output "bastion_host_public_ip_id" {
  description = "ID of the Bastion Host Public IP"
  value       = azurerm_public_ip.bastion_host_public_ip.id
}
output "bastion_host_public_ip" {
  description = "Bastion Host's public IP address"
  value = azurerm_public_ip.bastion_host_public_ip.ip_address
}
output "bastion_host_id" {
  description = "ID of the Bastion Host"
  value       = azurerm_bastion_host.cnsoln_bastion_host.id
}
