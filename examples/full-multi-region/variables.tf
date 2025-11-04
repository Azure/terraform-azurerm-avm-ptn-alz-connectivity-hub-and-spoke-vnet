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

variable "connectivity_type" {
  type        = string
  default     = "hub_and_spoke_vnet"
  description = "The type of network connectivity technology to use for the private DNS zones"
}

variable "custom_replacements" {
  type = object({
    names                      = optional(map(string), {})
    resource_group_identifiers = optional(map(string), {})
    resource_identifiers       = optional(map(string), {})
  })
  default = {
    names                      = {}
    resource_group_identifiers = {}
    resource_identifiers       = {}
  }
  description = "Custom replacements"
}

variable "enable_telemetry" {
  type        = bool
  default     = false
  description = "Flag to enable/disable telemetry"
}

variable "hub_and_spoke_networks_settings" {
  type        = any
  default     = {}
  description = <<DESCRIPTION
The shared settings for the hub and spoke networks. This is where global resources are defined.

The following attributes are supported:

  - ddos_protection_plan: (Optional) The DDoS protection plan settings. Detailed information about the DDoS protection plan can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-ddosprotectionplan

DESCRIPTION
}

variable "hub_virtual_networks" {
  type        = any
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

variable "management_group_settings" {
  type        = any
  default     = {}
  description = <<DESCRIPTION
The settings for the management groups. Details of the settings can be found in the module documentation at https://registry.terraform.io/modules/Azure/avm-ptn-alz
DESCRIPTION
}

variable "management_resource_settings" {
  type        = any
  default     = {}
  description = <<DESCRIPTION
The settings for the management resources. Details of the settings can be found in the module documentation at https://registry.terraform.io/modules/Azure/avm-ptn-alz-management
DESCRIPTION
}

variable "starter_locations" {
  type        = list(string)
  default     = ["uksouth", "ukwest"]
  description = "The default for Azure resources. (e.g 'uksouth')"
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}
