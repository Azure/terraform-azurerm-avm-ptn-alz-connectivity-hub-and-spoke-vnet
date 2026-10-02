terraform {
  required_version = "~> 1.12"

  required_providers {
    # azapi and modtm are used only by the called modules; declaring them lets
    # tests/unit/example_shared_keys.tftest.hcl replace them with mock providers.
    # tflint-ignore: terraform_unused_required_providers
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.21"
    }
    # tflint-ignore: terraform_unused_required_providers
    modtm = {
      source  = "Azure/modtm"
      version = "~> 0.3"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

locals {
  config_templating_inputs = {
    connectivity_resource_groups    = var.connectivity_resource_groups
    hub_and_spoke_networks_settings = var.hub_and_spoke_networks_settings
    hub_virtual_networks            = local.hub_virtual_networks_template
    management_group_settings       = var.management_group_settings
    management_resource_settings    = var.management_resource_settings
    tags                            = var.tags
    connectivity_tags               = var.connectivity_tags
  }
}

module "config" {
  source = "github.com/Azure/alz-terraform-accelerator//templates/platform_landing_zone/modules/config-templating?ref=main"

  custom_replacements             = var.custom_replacements
  inputs                          = local.config_templating_inputs
  starter_locations               = var.starter_locations
  subscription_id_connectivity    = data.azurerm_client_config.current.subscription_id
  subscription_id_identity        = data.azurerm_client_config.current.subscription_id
  subscription_id_management      = data.azurerm_client_config.current.subscription_id
  subscription_id_security        = data.azurerm_client_config.current.subscription_id
  enable_telemetry                = var.enable_telemetry
  root_parent_management_group_id = ""
}

module "resource_groups" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.0"
  for_each = module.config.outputs.connectivity_resource_groups

  location         = each.value.location
  name             = each.value.name
  enable_telemetry = var.enable_telemetry
  tags             = module.config.outputs.tags
}

# Build an implicit dependency on the resource groups
locals {
  hub_and_spoke_networks_settings = merge(module.config.outputs.hub_and_spoke_networks_settings, local.resource_groups)
  hub_virtual_networks            = (merge({ vnets = local.templated_config.hub_virtual_networks }, local.resource_groups)).vnets
  resource_groups = {
    resource_groups = module.resource_groups
  }
}

# This is the module call
module "test" {
  source = "../../"

  enable_telemetry                = var.enable_telemetry
  hub_and_spoke_networks_settings = local.hub_and_spoke_networks_settings
  hub_virtual_networks            = local.hub_virtual_networks
  tags                            = module.config.outputs.tags
}
