# backend.tf for env: test

terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~>3.0"
    }
  }

  // passed backend values in GitHub pipeline (terraform init section)
  backend "azurerm" {
  }
}
