terraform {
  required_version = ">= 1.12, < 2.0"

  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
    modtm = {
      source = "Azure/modtm"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}