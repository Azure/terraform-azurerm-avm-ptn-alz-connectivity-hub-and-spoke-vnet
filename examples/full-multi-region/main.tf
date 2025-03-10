terraform {
  required_version = "~> 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.21"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "starter_locations" {
  type        = list(string)
  description = "The default for Azure resources. (e.g 'uksouth')"
  default     = ["uksouth", "ukwest"]
}

variable "connectivity_resource_groups" {
  type = map(object({
    name     = string
    location = string
  }))
  default     = {}
  description = <<DESCRIPTION
A map of resource groups to create. These must be created before the connectivity module is applied.

The following attributes are supported:

  - name: The name of the resource group
  - location: The location of the resource group

DESCRIPTION
}

variable "hub_and_spoke_vnet_settings" {
  type        = any
  default     = {}
  description = <<DESCRIPTION
The shared settings for the hub and spoke networks. This is where global resources are defined.

The following attributes are supported:

  - ddos_protection_plan: (Optional) The DDoS protection plan settings. Detailed information about the DDoS protection plan can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-ddosprotectionplan

DESCRIPTION
}

variable "hub_and_spoke_vnet_virtual_networks" {
  type = map(object({
    hub_virtual_network = any
    virtual_network_gateways = optional(object({
      subnet_address_prefix = string
      express_route         = optional(any)
      vpn                   = optional(any)
    }))
    private_dns_zones = optional(any)
    bastion           = optional(any)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of hub networks to create.

The following attributes are supported:

  - hub_virtual_network: The hub virtual network settings. Detailed information about the hub virtual network can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-hubnetworking
  - virtual_network_gateways: (Optional) The virtual network gateway settings. Detailed information about the virtual network gateway can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-vnetgateway
  - private_dns_zones: (Optional) The private DNS zone settings. Detailed information about the private DNS zone can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-network-private-link-private-dns-zones
  - bastion: (Optional) The bastion host settings. Detailed information about the bastion can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-res-network-bastionhost/

DESCRIPTION
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

data "azurerm_client_config" "current" {}

module "config" {
  source           = "github.com/Azure/alz-terraform-accelerator//templates/platform_landing_zone/modules/config-templating"
  enable_telemetry = var.enable_telemetry

  starter_locations               = var.starter_locations
  subscription_id_connectivity    = data.azurerm_client_config.current.subscription_id
  subscription_id_identity        = data.azurerm_client_config.current.subscription_id
  subscription_id_management      = data.azurerm_client_config.current.subscription_id
  root_parent_management_group_id = ""

  custom_replacements = var.custom_replacements

  connectivity_resource_groups        = var.connectivity_resource_groups
  hub_and_spoke_vnet_settings         = var.hub_and_spoke_vnet_settings
  hub_and_spoke_vnet_virtual_networks = var.hub_and_spoke_vnet_virtual_networks
  management_resource_settings        = var.management_resource_settings
  management_group_settings           = var.management_group_settings
  tags                                = var.tags
}

module "resource_groups" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.0"

  for_each = module.config.connectivity_resource_groups

  name             = each.value.name
  location         = each.value.location
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

  hub_and_spoke_networks_settings = local.hub_and_spoke_vnet_settings
  hub_virtual_networks            = local.hub_and_spoke_vnet_virtual_networks
  enable_telemetry                = false
  tags                            = module.config.tags
}
