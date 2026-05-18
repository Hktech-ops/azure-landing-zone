// main.tf for module - compute

/* 
Goal is to deploy a VM with the following features
 - managed id + entra only login + VM admin RBAC role to entra group
 - link PaaS resources' private DNS zones to VM's vnet i.e. spoke vnet (to allow VM to access paas resources)
 - diagnostic setting + boot diagnostic for VM boot data
 - nsg (allow inbound from Vnets + Firewall) & explicitely deny all other inbound --> already attached to app subnet --> spoke vnet module!!
 - disks encryption at rest using PMKs --> automatically encrypted using PMK, no separate reference needed
 - VM backup via Recovery services vault
   - Recovery services vault --> referenced from module: platform
   - VM backup policy
   - Backup policy binding to VM
*/


# Standard_D2s_v3 - 2 vCPUs, 8 gigs of RAM, OS Disk = 1 TB, Data Disk = 16 gigs, SSD
# ---------------------------------------------------------

# ======================================
# VM
# ======================================

# tags
locals {
  common_tags = {
    author = "HK"
    env = "Prod"
  }
}

# VM's NIC
resource "azurerm_network_interface" "win_vm_nic" {
  resource_group_name = var.rg_name
  location = var.rg_location
  name = var.win_vm_nic_name

  ip_configuration {
    name = "${var.win_vm_nic_name}-ipconfig"
    subnet_id = var.app_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address = "192.168.0.4"  // private IP must be specified when it is static
  }
  tags = local.common_tags
}
# VM
resource "azurerm_windows_virtual_machine" "win_vm" {
  resource_group_name = var.rg_name
  location = var.rg_location
  name = var.win_vm_name
  size = "Standard_B4as_v2"  //Standard_D2s_v3 - 4 vCPUs, 16 gigs of RAM, OS Disk = 1 TB, Data Disk = upto 8 data disks, SSD
  // e2s v3 - 16 gigs of memory and 2 vcpus

  admin_username = var.win_vm_name  //same as vm name
  admin_password = random_password.vm_admin_random_pw.result // referred from random pw resource

  network_interface_ids = [ azurerm_network_interface.win_vm_nic.id ]

  // automatically encrypted using PMK
  os_disk {
    name = "${var.win_vm_name}-os-disk"
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }

  // for storing VM's boot diagnostics
  // azure will automatically create a container inside this storage account
  boot_diagnostics {
    storage_account_uri = var.storage_account_uri   //referenced from module: paas-resources
  }

  tags = local.common_tags
}
# for admin password - random pw generator
resource "random_password" "vm_admin_random_pw" {
  length = 32
  special = true
}
# Entra login extension for VM admin access
resource "azurerm_virtual_machine_extension" "entra_login_for_win_vm" {
  name                 = "AADLoginForWindows"
  virtual_machine_id   = azurerm_windows_virtual_machine.win_vm.id // win vm
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADLoginForWindows"
  type_handler_version = "1.0"

  tags = local.common_tags
}
# RBAC role - VM admin to vm admins group
resource "azurerm_role_assignment" "win_vm_admin_role" {
  scope = azurerm_windows_virtual_machine.win_vm.id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id = var.vm_admins_group_object_id  // referenced from module: iam
}

# VM - diagnostic setting - resource level for monitor. Sent to centralized LAW
resource "azurerm_monitor_diagnostic_setting" "win_vm_diagnostic_setting" {
  name = var.win_vm_diagnostic_setting_name
  target_resource_id = azurerm_windows_virtual_machine.win_vm.id
  log_analytics_workspace_id = var.law_id   // referenced from module: monitoring

  /* enabled_log {
    category_group = "Audit"
  }
  enabled_log {
    category_group = "AllLogs"
  } */
  metric {
    category = "AllMetrics"
    enabled = true
  }
}

# ==============================
# Backup for VM - backup policy, protected VM
# ==============================
resource "azurerm_backup_policy_vm" "backup_policy_vm" {
  resource_group_name = var.rg_name
  name = var.backup_policy_vm_name
  recovery_vault_name = var.cnsolns_recovery_services_vault_name    //referenced from module: platform

  timezone = "UTC"  //converted 23:00 EST to UTC

  backup {
    frequency = "Daily"
    time = "04:00"
  }
  retention_daily {
    count = 8   // has to be more than 7 days
  }
}
# binding - protected VM
resource "azurerm_backup_protected_vm" "backup_policy_vm_binding" {
  resource_group_name = var.rg_name
  recovery_vault_name = var.cnsolns_recovery_services_vault_name
  source_vm_id = azurerm_windows_virtual_machine.win_vm.id
  backup_policy_id = azurerm_backup_policy_vm.backup_policy_vm.id
}

