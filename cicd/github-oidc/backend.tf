# Backend config for github-oidc

# Purpose: State file for this project to be stored in a stand-alone storage a/c

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  # remote backend - stored to standalone storage account
  backend "azurerm" {
    resource_group_name  = "bluepeak-alz-remote-backend"
    storage_account_name = "bluepeakrbestorage"
    container_name       = "github-oidc-tfstate"
    key                  = "github-oidc.tfstate"
  }
}