variable "gateways_enabled" {
  type        = bool
  default     = true
  description = "Preserve the existing gateway enablement behavior."
}

variable "input_mode" {
  type        = string
  default     = "direct"
  description = "Select the direct, adapted template, or whole-configuration template input path."

  validation {
    condition     = contains(["direct", "template", "whole"], var.input_mode)
    error_message = "input_mode must select an existing regression path."
  }
}

variable "services" {
  type        = bool
  default     = false
  description = "Enable the firewall, Firewall Policy, Bastion, NAT gateway, private DNS zones, DNS resolver, resolver policy and gateway route tables."
}

variable "shared_keys" {
  type = object({
    er_connection  = string
    er_peering     = string
    er_local       = string
    vpn_connection = string
  })
  default = {
    er_connection  = "test-er-connection"
    er_peering     = "test-er-peering"
    er_local       = "test-er-local"
    vpn_connection = "test-vpn-connection"
  }
  description = "Distinct synthetic values for the four existing shared_key paths."
  sensitive   = true
}

variable "unknown_keys" {
  type        = bool
  default     = false
  description = "Keep shared keys unknown during the mocked plan."
}

variable "user_iterator_zone" {
  type        = bool
  default     = false
  description = "Add a caller-supplied private DNS zone that uses custom_iterator."
}