output "dns_server_ip_addresses" {
  description = "DNS server IP addresses for each hub virtual network."
  value       = { for key, value in local.hub_virtual_networks : key => try(value.hub_router_ip_address, try(module.hub_and_spoke_vnet.firewalls[key].private_ip_address, null)) }
}

output "firewall_policies" {
  description = "Firewall policies for each hub virtual network."
  value       = module.hub_and_spoke_vnet.firewall_policies
}

output "firewall_private_ip_addresses" {
  description = "Private IP addresses of the firewalls."
  value       = { for key, value in module.hub_and_spoke_vnet.firewalls : key => value.private_ip_address }
}

output "firewall_public_ip_addresses" {
  description = "Public IP addresses of the firewalls."
  value       = { for key, value in module.hub_and_spoke_vnet.firewalls : key => value.public_ip_addresses }
}

output "firewall_resource_ids" {
  description = "Resource IDs of the firewalls."
  value       = { for key, value in module.hub_and_spoke_vnet.firewalls : key => value.id }
}

output "firewall_resource_names" {
  description = "Resource names of the firewalls."
  value       = { for key, value in module.hub_and_spoke_vnet.firewalls : key => value.name }
}

output "name" {
  description = "Names of the virtual networks"
  value       = { for key, value in module.hub_and_spoke_vnet.virtual_networks : key => value.name }
}

output "private_dns_zone_resource_ids" {
  description = "Resource IDs of the private DNS zones"
  value       = { for key, value in module.private_dns_zones : key => value.private_dns_zone_resource_ids }
}

output "private_link_private_dns_zone_with_network_links" {
  description = "Private link private DNS zone links"
  value       = local.private_dns_zones
}

output "resource_id" {
  description = "Resource IDs of the virtual networks"
  value       = { for key, value in module.hub_and_spoke_vnet.virtual_networks : key => value.id }
}

output "route_tables_firewall" {
  description = "Route tables associated with the firewall."
  value       = module.hub_and_spoke_vnet.hub_route_tables_firewall
}

output "route_tables_gateway_resource_ids" {
  description = "Route tables associated with the gateway subnet."
  value       = { for key, value in module.gateway_route_table : key => value.resource_id }
}

output "route_tables_user_subnets" {
  description = "Route tables associated with the user subnets."
  value       = module.hub_and_spoke_vnet.hub_route_tables_user_subnets
}

output "virtual_network_resource_ids" {
  description = "Resource IDs of the virtual networks."
  value       = { for key, value in module.hub_and_spoke_vnet.virtual_networks : key => value.id }
}

output "virtual_network_resource_names" {
  description = "Resource names of the virtual networks."
  value       = { for key, value in module.hub_and_spoke_vnet.virtual_networks : key => value.name }
}
