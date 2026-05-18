// outputs.tf for module: spoke-network

# ============================
# Spoke VNet
# ============================
output "spoke_vnet_id" {
  description = "ID of the Spoke Virtual Network"
  value       = azurerm_virtual_network.spoke_vnet.id
}
output "spoke_vnet_name" {
  description = "Name of the Spoke Virtual Network"
  value       = azurerm_virtual_network.spoke_vnet.name
}
output "spoke_vnet_address_space" {
  description = "Address space of the Spoke Virtual Network"
  value       = azurerm_virtual_network.spoke_vnet.address_space
}

# ============================
# Subnets
# ============================
output "app_subnet_id" {
  description = "ID of the App subnet"
  value       = azurerm_subnet.app_subnet.id
}
output "app_subnet_cidr" {
  description = "CIDR of the App subnet"
  value       = azurerm_subnet.app_subnet.address_prefixes[0]
}
output "database_subnet_id" {
  description = "ID of the Database subnet"
  value       = azurerm_subnet.database_subnet.id
}
output "database_subnet_cidr" {
  description = "CIDR of the Database subnet"
  value       = azurerm_subnet.database_subnet.address_prefixes[0]
}
output "workload_subnet_id" {
  description = "ID of the Workload subnet"
  value       = azurerm_subnet.workload_subnet.id
}
output "workload_subnet_cidr" {
  description = "CIDR of the Workload subnet"
  value       = azurerm_subnet.workload_subnet.address_prefixes[0]
}

# ============================
# Route Table
# ============================
output "spoke_subnets_rt_id" {
  description = "ID of the Route Table associated with all Spoke subnets"
  value       = azurerm_route_table.spoke_subnets_rt.id
}

# ============================
# NSGs
# ============================
output "app_nsg_id" {
  description = "ID of the App + Database NSG"
  value       = azurerm_network_security_group.app_nsg.id
}
output "database_nsg_id" {
  description = "ID of the Database NSG"
  value = azurerm_network_security_group.database_nsg.id
}
output "workload_nsg_id" {
  description = "ID of the Workload NSG"
  value       = azurerm_network_security_group.workload_nsg.id
}

# ============================
# private DNS Zone Links
# ============================
output "monitor_private_dns_zone_to_spokevnet_link_id" {
  description = "ID of the Monitor Private DNS Zone link to Spoke VNet"
  value       = azurerm_private_dns_zone_virtual_network_link.monitor_private_dns_zone_to_spokevnet_link.id
}
output "oms_private_dns_zone_to_spokevnet_link_id" {
  description = "ID of the OMS Private DNS Zone link to Spoke VNet"
  value       = azurerm_private_dns_zone_virtual_network_link.oms_private_dns_zone_to_spokevnet_link.id
}
output "ods_private_dns_zone_to_spokevnet_link_id" {
  description = "ID of the ODS Private DNS Zone link to Spoke VNet"
  value       = azurerm_private_dns_zone_virtual_network_link.ods_private_dns_zone_to_spokevnet_link.id
}

# ============================
# VNet Peerings
# ============================
output "hub_to_spoke_peering_id" {
  description = "ID of the Hub-to-Spoke VNet Peering"
  value       = azurerm_virtual_network_peering.hub_to_spoke_peering.id
}
output "spoke_to_hub_peering_id" {
  description = "ID of the Spoke-to-Hub VNet Peering"
  value       = azurerm_virtual_network_peering.spoke_to_hub_peering.id
}
