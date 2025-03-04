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

module "shared" {
  source = "../modules/shared"
  custom_replacements = var.custom_replacements
  hub_and_spoke_vnet_settings = var.hub_and_spoke_vnet_settings
  hub_and_spoke_vnet_virtual_networks = var.hub_and_spoke_vnet_virtual_networks
  connectivity_resource_groups = var.connectivity_resource_groups
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"

  hub_and_spoke_networks_settings = module.shared.hub_and_spoke_networks_settings
  hub_virtual_networks            = module.shared.hub_virtual_networks
  enable_telemetry                = false
  tags                            = var.tags
}
