variable "custom_replacements" {
  type        = any
  default     = {}
  description = "The same replacement context for the original and adapted templates."
}

variable "hub_virtual_networks" {
  type        = any
  default     = {}
  description = "Original example input, including synthetic shared_key values."
}