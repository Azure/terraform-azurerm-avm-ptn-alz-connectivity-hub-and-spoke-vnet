variable "enable_telemetry" {
  type        = bool
  default     = true
  nullable    = false
  description = "Whether telemetry is enabled for the module."
}

variable "location" {
  type        = string
  default     = "swedencentral"
  nullable    = false
  description = "The Azure region in which the example resources are deployed."
}
