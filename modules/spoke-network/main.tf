// main.tf for module: spoke-network

/* 
Spoke Vnet = 192.168.0.0/22 - total 1024 ips
  - app subnet = 192.168.0.0/24 (for VMs, App services, APIs)
  - database subnet = 192.168.1.0/24 (for self-managed DB/VM based SQL DB like Azure SQL Database, Mongo DB)
  - workload subnet = 192.168.2.0/24 (for AKS clusters and containers)
  
  - 192.168.3.0/24 - 256 ips free for future expansion

Spoke subnets Route Table - associated to all 3 subnets (app, database, workload)
  - route to Internet via Firewall (just one UDR)

  - following System Defined routes are already created by Azure:
   - system defined route to Vnet local (spoke vnet is already created)
   - plus, since both hub and spoke are peered, system also created route from peered (hub) vnet


NSGs with varying rules associated to respective subnets
  - app nsg
   - rules : Allow inbound from both Vnets, Firewall + DENY from ALL other sources
   - destination ports = 80, 443
   - explicitely block inbound from Internet

  - database nsg
   - Allow inbound from Hub, Firewall + DENY from ALL other sources
   - destination port = 1433
   - explicitely block inbound from Internet

  - workload nsg - associated with workload nsg
    - rules: llow inbound from both Vnets, Firewall + DENY from ALL other sources
    - destination ports = * for now, change later as per requirements
    - explicitely block inbound from Internet

Bi-directional Vnet peering hub vnet <--> spoke vnet

Link private DNS zones for monitor, oms, ods to Spoke Vnet (disable public ingestion & querying of logs)
*/

# -------------------------------------------------------------------

# tags
locals {
  common_tags = {
    author = "HK"
    env    = "Prod"
  }
}

# ==================================
# Spoke Vnet and its 3 subnets
# ==================================
resource "azurerm_virtual_network" "spoke_vnet" {
  resource_group_name = var.rg_name
  location            = var.rg_location
  name                = var.spoke_vnet_name

  address_space = ["192.168.0.0/22"] // total 1024 ips

  tags = local.common_tags
}
resource "azurerm_subnet" "app_subnet" {
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  name                 = var.app_subnet_name

  address_prefixes = ["192.168.0.0/24"] //256 ips for app subnet
}
resource "azurerm_subnet" "database_subnet" {
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  name                 = var.database_subnet_name

  address_prefixes = ["192.168.1.0/24"] //256 ips for database subnet
}
resource "azurerm_subnet" "workload_subnet" {
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  name                 = var.workload_subnet_name

  address_prefixes = ["192.168.2.0/24"] //256 ips for workload subnet
}

//192.168.3.0/24 - 256 ips free for future expansion


# ============================================
# Peering: hub-network with spoke-network (Bi-directional peering)
# Peering logs - covered under Activity logs
# ============================================
// hub to spoke peering
resource "azurerm_virtual_network_peering" "hub_to_spoke_peering" {
  name                      = "hub-to-spoke-peering"
  resource_group_name       = var.rg_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.spoke_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
// spoke to hub peering
resource "azurerm_virtual_network_peering" "spoke_to_hub_peering" {
  name                      = "spoke-to-hub-peering"
  resource_group_name       = var.rg_name
  virtual_network_name      = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id = var.hub_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# ============================================
# Common Route Table for each subnets and thier associaton to all 3 subnets
# spoke-subnets-rt : common route table for 3 subnets - app, database and workload subnets!
# goal is to route outbound traffic via Firewall
# ============================================
resource "azurerm_route_table" "spoke_subnets_rt" {
  resource_group_name = var.rg_name
  location            = var.rg_location
  name                = var.spoke_subnets_rt

  tags = local.common_tags

  // Route to Internet via Firewall ---> had to comment out as i wanted to delete firewall - NOTHING WRONG with it, you can reisntate it!
  route {
    name                   = "toInternetviaFirewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.hub_firewall_private_ip_address // hub-firewall's private ip address
  }
}
// associate spoke_subnets_rt to app_subnet
resource "azurerm_subnet_route_table_association" "spoke_subnets_rt_to_app_subnet" {
  route_table_id = azurerm_route_table.spoke_subnets_rt.id
  subnet_id      = azurerm_subnet.app_subnet.id // app subnet
}
// associate spoke_subnets_rt to database_subnet
resource "azurerm_subnet_route_table_association" "spoke_subnets_rt_to_database_subnet" {
  route_table_id = azurerm_route_table.spoke_subnets_rt.id
  subnet_id      = azurerm_subnet.database_subnet.id //database subnet
}
// associate spoke_subnets_rt to workload_subnet
resource "azurerm_subnet_route_table_association" "spoke_subnets_rt_to_workload_subnet" {
  route_table_id = azurerm_route_table.spoke_subnets_rt.id
  subnet_id      = azurerm_subnet.workload_subnet.id //workload subnet
}

# ============================================
# app-nsg : to be associated with app database subnet
# rules : Allow inbound from both Vnets, Firewall + DENY from ALL other sources
# destination port ranges = 80,443
# ============================================
# app NSG
resource "azurerm_network_security_group" "app_nsg" {
  resource_group_name = var.rg_name
  location            = var.rg_location
  name                = var.app_nsg_name

  tags = local.common_tags

  security_rule {
    name                       = "allowInboundfromHubVnet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefixes    = [var.hub_vnet_address_space[0]] // hub Vnet
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"] // Allow HTTP and HTTPS traffic
    destination_address_prefix = "*"           // it is associated to app subnet
  }
  security_rule {
    name                       = "allowInboundfromFirewall"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = var.hub_firewall_private_ip_address //  firewall's private ip
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"] // HTTP and HTTPS traffic
    destination_address_prefix = "*"           // it is associated to app + database subnets
  }

  //expicitely deny ALL other traffic from INTERNET ***
  security_rule {
    name                       = "denyFromInternet"
    priority                   = 1500
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "Internet"
    source_port_range          = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*" // it is associated to app + database subnets
  }
}
// associate to app-subnet
resource "azurerm_subnet_network_security_group_association" "app_nsg_to_app_subnet" {
  subnet_id                 = azurerm_subnet.app_subnet.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

# Diagnostic setting for app-nsg
resource "azurerm_monitor_diagnostic_setting" "app_nsg_diagnostic_setting" {
  name                       = var.app_nsg_diagnostic_setting_name
  target_resource_id         = azurerm_network_security_group.app_nsg.id
  log_analytics_workspace_id = var.law_id // send to central LAW

  enabled_log {
    category = "NetworkSecurityGroupEvent" // Logs for allowed or denied flows
  }
  enabled_log {
    category = "NetworkSecurityGroupRuleCounter" // Rule hit counts 
  }
}

# ==================================================
# database-nsg : to be associated with database-subnet
# rules : Allow inbound from Hub, Firewall + DENY from ALL other sources
# destination port ranges are 1433 for database for now, can be changed later as per the requirement
# ==================================================
# Database NSG
resource "azurerm_network_security_group" "database_nsg" {
  resource_group_name = var.rg_name
  location            = var.rg_location
  name                = var.database_nsg_name

  tags = local.common_tags

  security_rule {
    name                       = "allowInboundfromHubVnet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefixes    = [var.hub_vnet_address_space[0]] // hub Vnet
    source_port_range          = "*"
    destination_port_ranges    = ["1433"]
    destination_address_prefix = "*" // it is associated to database subnet
  }
  security_rule {
    name                       = "allowInboundfromFirewall"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = var.hub_firewall_private_ip_address //  firewall's private ip
    source_port_range          = "*"
    destination_port_ranges    = ["1433"]
    destination_address_prefix = "*" // it is associated to database subnet
  }

  //expicitely deny ALL other traffic from INTERNET ***
  security_rule {
    name                       = "denyFromInternet"
    priority                   = 1500
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "Internet"
    source_port_range          = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*" // it is associated to app + database subnets
  }
}

// associate to database-subnet
resource "azurerm_subnet_network_security_group_association" "database_subnet_nsg_to_database_subnet" {
  subnet_id                 = azurerm_subnet.database_subnet.id
  network_security_group_id = azurerm_network_security_group.database_nsg.id
}

# Diagnostic setting for database-nsg
resource "azurerm_monitor_diagnostic_setting" "database_nsg_diagnostic_setting" {
  name                       = var.database_nsg_diagnostic_setting_name
  target_resource_id         = azurerm_network_security_group.database_nsg.id
  log_analytics_workspace_id = var.law_id // send to central LAW

  enabled_log {
    category = "NetworkSecurityGroupEvent" // Logs for allowed or denied flows
  }
  enabled_log {
    category = "NetworkSecurityGroupRuleCounter" // Rule hit counts 
  }
}

# ==================================================
# workload-nsg : to be associated with workload-subnet
# rules : Allow inbound from both Vnets, Firewall + DENY from ALL other sources
# destination port ranges are * for now, can be changed later as per the requirement
# ==================================================
# workload NSG
resource "azurerm_network_security_group" "workload_nsg" {
  resource_group_name = var.rg_name
  location            = var.rg_location
  name                = var.workload_nsg_name

  tags = local.common_tags

  security_rule {
    name      = "allowInboundfromHubVnet"
    priority  = 110
    direction = "Inbound"
    access    = "Allow"
    protocol  = "Tcp"

    source_address_prefixes = [var.hub_vnet_address_space[0]] //from module: hub-network
    source_port_range       = "*"

    destination_address_prefixes = [azurerm_subnet.workload_subnet.address_prefixes[0]] // workload subnet address space
    destination_port_range       = "*"
  }

  security_rule {
    name      = "allowInboundfromFirewall"
    priority  = 120
    direction = "Inbound"
    access    = "Allow"
    protocol  = "Tcp"

    source_address_prefixes = [var.hub_firewall_private_ip_address] // firewall private ip
    source_port_range       = "*"

    destination_address_prefixes = [azurerm_subnet.workload_subnet.address_prefixes[0]] // workload subnet
    destination_port_range       = "*"
  }

  security_rule {
    name      = "denyFromInternet"
    priority  = 1500
    direction = "Inbound"
    access    = "Deny"
    protocol  = "*"

    source_address_prefixes = ["0.0.0.0/0"]
    source_port_range       = "*"

    destination_address_prefixes = [azurerm_subnet.workload_subnet.address_prefixes[0]] // workload subnet
    destination_port_range       = "*"
  }

}
// associate workload nsg to workload subnet
resource "azurerm_subnet_network_security_group_association" "workload_nsg_to_workload_subnet" {
  subnet_id                 = azurerm_subnet.workload_subnet.id
  network_security_group_id = azurerm_network_security_group.workload_nsg.id
}

# Disgnostic setting for workload nsg
resource "azurerm_monitor_diagnostic_setting" "workload_nsg_diagnostic_setting" {
  name                       = var.workload_nsg_diagnostic_setting_name
  target_resource_id         = azurerm_network_security_group.workload_nsg.id
  log_analytics_workspace_id = var.law_id // send to central LAW

  enabled_log {
    category = "NetworkSecurityGroupEvent" // Logs for allowed or denied flows
  }
  enabled_log {
    category = "NetworkSecurityGroupRuleCounter" // Rule hit counts 
  }
}


# ===============================
# Link monitor, oms, ods private DNS zones to Spoke Vnet - for Monitoring
# recall there 3 private DNS zones were provisioned in module hub-network
# ===============================
resource "azurerm_private_dns_zone_virtual_network_link" "monitor_private_dns_zone_to_spokevnet_link" {
  resource_group_name   = var.rg_name
  name                  = var.monitor_private_dns_zone_to_spokevnet_link_name
  private_dns_zone_name = var.monitor_private_dns_zone_name     // referenced from module: hub-network
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id // id of Spoke vnet

  tags = local.common_tags
}
resource "azurerm_private_dns_zone_virtual_network_link" "oms_private_dns_zone_to_spokevnet_link" {
  resource_group_name   = var.rg_name
  name                  = var.oms_private_dns_zone_to_spokevnet_link_name
  private_dns_zone_name = var.oms_private_dns_zone_name         // referenced from module: hub-network
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id // id of Spoke vnet

  tags = local.common_tags
}
resource "azurerm_private_dns_zone_virtual_network_link" "ods_private_dns_zone_to_spokevnet_link" {
  resource_group_name   = var.rg_name
  name                  = var.ods_private_dns_zone_to_spokevnet_link_name
  private_dns_zone_name = var.ods_private_dns_zone_name         // referenced from module: hub-network
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id // id of Spoke vnet

  tags = local.common_tags
}

