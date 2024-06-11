terraform {
  required_version = ">= 1.8.4"

  backend "azurerm" {
    # This will not be needed for terraform cli version 1.2.x and above (as it will be enabled by default)
    use_microsoft_graph = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.107.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.azure_provider_default.subscription_id
  tenant_id       = var.azure_provider_default.tenant_id
  features {}
}