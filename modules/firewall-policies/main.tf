// main.tf for module: firewall policies

/* 
firewall policy
firewall policy rules collection groups : 3
 
 - dnat rules collection group
  - inbound from internet on 80 & 443, translated to VM's private IP
   - Why? I have deployed SPA on VM

 - network rules collection group
  - allowed ALL outbound from VM 

 - application rules collection group
  - allowed all FQDNs from VM

 */
# ---------------------------------------------

# tags
locals {
  common_tags = {
    author = "HK"
    env    = "Prod"
  }
}

# ==============================
# Firewall policy
# ==============================
# Firewall policy
resource "azurerm_firewall_policy" "hub_firewall_policy" {
  resource_group_name = var.rg_name
  location            = var.rg_location
  name                = var.hub_firewall_policy_name

  sku = "Standard"

  threat_intelligence_mode = "Alert"
  //threat_intelligence_mode = "AlertAndDeny"

  tags = local.common_tags
}

# ============================================================
# DNAT RULES (INBOUND)
# ============================================================
resource "azurerm_firewall_policy_rule_collection_group" "dnat_rules_cg" {
  name               = var.dnat_rules_cg_name
  firewall_policy_id = azurerm_firewall_policy.hub_firewall_policy.id
  priority           = 100

  nat_rule_collection {
    name     = "inbound-web"
    priority = 100
    action   = "Dnat"

    rule {
      name              = "http-to-appvm"
      protocols         = ["TCP"]
      source_addresses  = ["*"]
      destination_ports = ["80"]

      destination_address = var.hub_firewall_public_ip_address

      translated_address = var.win_vm_private_ip //vm's private IP
      translated_port    = "80"
    }

    rule {
      name                = "https-to-appvm"
      protocols           = ["TCP"]
      source_addresses    = ["*"]
      destination_ports   = ["443"]
      destination_address = var.hub_firewall_public_ip_address
      translated_address  = var.win_vm_private_ip //vm's private IP
      translated_port     = "443"
    }
  }
}


# ============================================================
# NETWORK RULES (OUTBOUND)
# ============================================================
resource "azurerm_firewall_policy_rule_collection_group" "network_rules_cg" {
  name               = var.network_rules_cg_name
  firewall_policy_id = azurerm_firewall_policy.hub_firewall_policy.id
  priority           = 200

  network_rule_collection {
    name     = "allow-all-network"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "allow-all-outbound"
      protocols             = ["Any"]
      source_addresses      = [var.app_subnet_cidr] //[ var.hub_firewall_private_ip_address ] //private IP of firewall
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }
}


# ============================================================
# APPLICATION RULES (OUTBOUND)
# ============================================================
resource "azurerm_firewall_policy_rule_collection_group" "app_rules_cg" {
  name               = var.app_rules_cg_name
  firewall_policy_id = azurerm_firewall_policy.hub_firewall_policy.id
  priority           = 300

  application_rule_collection {
    name     = "allow-web-outbound"
    priority = 100
    action   = "Allow"

    rule {
      name             = "allow-http-https"
      source_addresses = [var.app_subnet_cidr] //[var.hub_firewall_private_ip_address]  // private IP of firewall

      protocols {
        type = "Http"
        port = 80
      }

      protocols {
        type = "Https"
        port = 443
      }

      destination_fqdns = ["*"]
    }
  }
}

