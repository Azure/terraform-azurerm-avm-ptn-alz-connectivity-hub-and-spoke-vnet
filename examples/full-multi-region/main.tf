terraform {
  required_version = "~> 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.21"
    }
  }
}

provider "azurerm" {
  features {}
}






data "azurerm_client_config" "current" {}

module "config" {
  source = "github.com/Azure/alz-terraform-accelerator//templates/platform_landing_zone/modules/config-templating?ref=main"

  connectivity_resource_groups        = var.connectivity_resource_groups
  custom_replacements                 = var.custom_replacements
  enable_telemetry                    = var.enable_telemetry
  hub_and_spoke_vnet_settings         = var.hub_and_spoke_vnet_settings
  hub_and_spoke_vnet_virtual_networks = var.hub_and_spoke_vnet_virtual_networks
  management_group_settings           = var.management_group_settings
  management_resource_settings        = var.management_resource_settings
  root_parent_management_group_id     = ""
  starter_locations                   = var.starter_locations
  subscription_id_connectivity        = data.azurerm_client_config.current.subscription_id
  subscription_id_identity            = data.azurerm_client_config.current.subscription_id
  subscription_id_management          = data.azurerm_client_config.current.subscription_id
  subscription_id_security            = data.azurerm_client_config.current.subscription_id
  tags                                = var.tags
}

module "resource_groups" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.0"
  for_each = module.config.connectivity_resource_groups

  location         = each.value.location
  name             = each.value.name
  enable_telemetry = false
  tags             = module.config.tags
}

# Build an implicit dependency on the resource groups
locals {
  hub_and_spoke_vnet_settings         = merge(module.config.hub_and_spoke_vnet_settings, local.resource_groups)
  hub_and_spoke_vnet_virtual_networks = (merge({ vnets = module.config.hub_and_spoke_vnet_virtual_networks }, local.resource_groups)).vnets
  resource_groups = {
    resource_groups = module.resource_groups
  }
}

# This is the module call
module "test" {
  source = "../../"

  enable_telemetry                = false
  hub_and_spoke_networks_settings = local.hub_and_spoke_vnet_settings
  hub_virtual_networks            = local.hub_and_spoke_vnet_virtual_networks
  tags                            = module.config.tags
}
