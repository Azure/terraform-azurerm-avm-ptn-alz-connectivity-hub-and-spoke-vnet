variable "private_link_private_dns_zone_virtual_network_link_moved_block_template_module_prefix" {
  type        = string
  default     = ""
  description = <<DESCRIPTION
(Optional) A prefix to use for the moved block template module for virtual network links.

NOTE: This is a temporary variable to support migration to the new module and will be moved in the next major version.
DESCRIPTION
}
