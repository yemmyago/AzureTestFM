terraform {
  required_version = ">= 1.6.6"

  backend "azurerm" {
    tenant_id            = "aa3ba334-375c-4f89-8679-aacd7f308101"
    subscription_id      = "35b62742-ab17-4688-b514-8f1efbd6e1d5"
    resource_group_name  = "rg-fmtest-sb-eus2"
    storage_account_name = "safmtestsbeus2"
    container_name       = "blob-fmtest-tfstate"
    key                  = "AzureTestFM/tfstate"


  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.107.0"
    }
  }
}

provider "azurerm" {

  features {}

  subscription_id = ${{ secrets.ARM_SUBSCRIPTION_ID }}
  tenant_id       = ${{ secrets.ARM_TENANT_ID }}
  client_id       = ${{ secrets.ARM_CLIENT_ID }}
  client_secret   = ${{ secrets.ARM_CLIENT_SECRET }}
  
  
}