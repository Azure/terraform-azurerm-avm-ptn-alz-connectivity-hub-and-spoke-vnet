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
