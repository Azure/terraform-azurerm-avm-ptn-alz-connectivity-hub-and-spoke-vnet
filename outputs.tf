output "bastion_host_dns_names" {
  description = "The bastion host resources associated with the virtual WAN, grouped by hub key."
  value       = { for key, value in module.bastion_host : key => value.dns_name }
}

output "bastion_host_public_ip_address" {
  description = "The public IP addresses of the bastion hosts associated with the virtual WAN, grouped by hub key."
  value       = { for key, value in module.bastion_public_ip : key => value.public_ip_address }
}

output "bastion_host_resource_ids" {
  description = "The resource IDs of the bastion hosts associated with the virtual WAN, grouped by hub key."
  value       = { for key, value in module.bastion_host : key => value.resource_id }
}

output "dns_server_ip_addresses" {
  description = "DNS server IP addresses for each hub virtual network."
  value       = { for key, value in local.hub_virtual_networks : key => value.hub_router_ip_address != null ? value.hub_router_ip_address : (local.firewall_enabled[key] ? module.hub_and_spoke_vnet.firewalls[key].private_ip_address : null) }
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
