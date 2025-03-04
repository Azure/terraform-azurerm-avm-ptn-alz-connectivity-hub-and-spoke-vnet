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


variable "management_resource_settings" {
  type        = any
  default     = {}
  description = <<DESCRIPTION
The settings for the management resources. Details of the settings can be found in the module documentation at https://registry.terraform.io/modules/Azure/avm-ptn-alz-management
DESCRIPTION
}

variable "management_group_settings" {
  type        = any
  default     = {}
  description = <<DESCRIPTION
The settings for the management groups. Details of the settings can be found in the module documentation at https://registry.terraform.io/modules/Azure/avm-ptn-alz
DESCRIPTION
}

variable "connectivity_type" {
  type        = string
  description = "The type of network connectivity technology to use for the private DNS zones"
  default     = "hub_and_spoke_vnet"
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

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = "Flag to enable/disable telemetry"
}
