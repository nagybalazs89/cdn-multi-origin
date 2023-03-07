terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.44"
    }
    azapi = {
      source = "azure/azapi"
      version = "~>1.3"
    }
  }
}