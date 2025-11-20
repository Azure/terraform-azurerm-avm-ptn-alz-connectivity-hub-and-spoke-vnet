output "private_link_private_dns_zone_virtual_network_link_moved_blocks" {
  description = <<DESCRIPTION
Moved blocks for private link private DNS zone virtual network links.

NOTE: This is a temporary output to support migration to the new module and will be moved in the next major version.
DESCRIPTION
  value       = local.moved_blocks_final
}
