# main.tf for env: test

# my trigger


module "platform" {
  source = "../../modules/platform"

  subscription_id      = var.subscription_id      //keyed value in tfvars 
  tenant_root_group_id = var.tenant_root_group_id //keyed value in tfvars 
}