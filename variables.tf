variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "hub_and_spoke_networks_settings" {
  type        = any
  default     = {}
  description = <<DESCRIPTION
The shared settings for the hub and spoke networks. This is where global resources are defined.

The following attributes are supported:

  - ddos_protection_plan: (Optional) The DDoS protection plan settings. Detailed information about the DDoS protection plan can be found in the module's README: <https://registry.terraform.io/modules/Azure/avm-res-network-ddosprotectionplan/azurerm/latest>

DESCRIPTION
}

variable "hub_virtual_networks" {
  type = map(object({
    hub_virtual_network = any
    bastion = optional(object({
      enabled                                = optional(bool, true)
      subnet_address_prefix                  = string
      subnet_default_outbound_access_enabled = optional(bool, false)
      bastion_host                           = any
      bastion_public_ip                      = any
    }))
    virtual_network_gateways = optional(object({
      subnet_address_prefix                  = string
      subnet_default_outbound_access_enabled = optional(bool, false)
      express_route                          = optional(any)
      vpn                                    = optional(any)
    }))
    private_dns_zones = optional(object({
      enabled                                    = optional(bool, true)
      dns_zones                                  = any
      auto_registration_zone_enabled             = optional(bool, true)
      auto_registration_zone_name                = optional(string, null)
      auto_registration_zone_resource_group_name = optional(string, null)
    }))
    private_dns_resolver = optional(object({
      enabled                                = optional(bool, true)
      subnet_address_prefix                  = string
      subnet_name                            = optional(string, "dns-resolver")
      subnet_default_outbound_access_enabled = optional(bool, false)
      dns_resolver                           = any
    }))
  }))
  default     = {}
  description = <<DESCRIPTION
A map of hub networks to create.

The following attributes are supported:

  - hub_virtual_network: The hub virtual network settings. Detailed information about the hub virtual network can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-hubnetworking
  - bastion: (Optional) The bastion host settings. Detailed information about the bastion can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-res-network-bastionhost/
  - virtual_network_gateways: (Optional) The virtual network gateway settings. Detailed information about the virtual network gateway can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-vnetgateway
  - private_dns_zones: (Optional) The private DNS zone settings. Detailed information about the private DNS zone can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-network-private-link-private-dns-zones
  - private_dns_resolver: (Optional) The private DNS resolver settings. Detailed information about the private DNS resolver can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-res-network-dnsresolver

DESCRIPTION
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}
