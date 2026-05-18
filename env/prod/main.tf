// main.tf for env - prod

module "platform" {
  source = "../../modules/platform"

  subscription_id      = var.subscription_id      //keyed value in tfvars 
  tenant_root_group_id = var.tenant_root_group_id //keyed value in tfvars 
}

module "monitoring" {
  source = "../../modules/monitoring"

  rg_name     = module.platform.rg_name     //referenced from platform module
  rg_location = module.platform.rg_location //referenced from platform module
}

module "policies" {
  source = "../../modules/policies"

  workloads_corp_mg_id = module.platform.workloads_corp_mg_id //referenced from platform module
  law_id               = module.monitoring.law_id             //referenced from monitoring module
  subscription_id      = var.subscription_id                  //keyed value in tfvars 
  rg_location          = module.platform.rg_location          //referenced from platform module
}

module "iam" {
  source = "../../modules/iam"
}

module "hub-network" {
  source = "../../modules/hub-network"

  rg_name     = module.platform.rg_name     //referenced from platform module
  rg_location = module.platform.rg_location //referenced from platform module
  law_id      = module.monitoring.law_id    //referenced from monitoring module

  hub_firewall_policy_id = module.firewall-policies.hub_firewall_policy_id // from module: firewall-policies

  //deployed bare firewall first, then privisioned firewall policies and then added policy to firewall
}

module "spoke-network" {
  source = "../../modules/spoke-network"

  rg_name                = module.platform.rg_name
  rg_location            = module.platform.rg_location
  law_id                 = module.monitoring.law_id
  hub_vnet_name          = module.hub-network.hub_vnet_name
  hub_vnet_id            = module.hub-network.hub_vnet_id
  hub_vnet_address_space = module.hub-network.hub_vnet_address_space

  monitor_private_dns_zone_name = module.hub-network.monitor_private_dns_zone_name
  oms_private_dns_zone_name     = module.hub-network.oms_private_dns_zone_name
  ods_private_dns_zone_name     = module.hub-network.ods_private_dns_zone_name

  hub_firewall_private_ip_address = module.hub-network.hub_firewall_private_ip_address //from hub-network
}

module "paas-resources" {
  source = "../../modules/paas-resources"

  tenant_id                               = var.tenant_id
  rg_name                                 = module.platform.rg_name
  rg_location                             = module.platform.rg_location
  law_id                                  = module.monitoring.law_id
  key_vault_admins_group_object_id        = module.iam.key_vault_admins_group_object_id
  acr_managers_group_object_id            = module.iam.acr_managers_group_object_id
  storage_ac_contributors_group_object_id = module.iam.storage_ac_contributors_group_object_id

  hub_vnet_id                 = module.hub-network.hub_vnet_id
  spoke_vnet_id               = module.spoke-network.spoke_vnet_id
  private_endpoints_subnet_id = module.hub-network.private_endpoints_subnet_id

  sql_admins_object_id  = module.iam.sql_admins_group_object_id
  sql_admins_group_name = module.iam.sql_admins_group_name
}

module "compute" {
  source = "../../modules/compute"

  rg_name                              = module.platform.rg_name
  rg_location                          = module.platform.rg_location
  law_id                               = module.monitoring.law_id
  app_subnet_id                        = module.spoke-network.app_subnet_id
  storage_account_uri                  = module.paas-resources.storage_account_uri
  vm_admins_group_object_id            = module.iam.vm_admins_group_object_id
  cnsolns_recovery_services_vault_name = module.platform.cnsolns_recovery_services_vault_name
}

module "firewall-policies" {
  source = "../../modules/firewall-policies"

  rg_name     = module.platform.rg_name
  rg_location = module.platform.rg_location

  hub_firewall_private_ip_address = module.hub-network.hub_firewall_private_ip_address
  hub_firewall_public_ip_address  = module.hub-network.hub_firewall_public_ip_address

  win_vm_private_ip = module.compute.win_vm_private_ip //from module: compute

  app_subnet_cidr = module.spoke-network.app_subnet_cidr // from module: spoke-network

}