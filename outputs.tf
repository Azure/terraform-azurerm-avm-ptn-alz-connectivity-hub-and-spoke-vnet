output "bastion_host_dns_names" {
  description = "The bastion host resources associated with the virtual WAN, grouped by hub key."
  value       = { for key, value in module.bastion_host : key => value.dns_name }
}

output "bastion_host_public_ip_address" {
  description = "The public IP addresses of the bastion hosts associated with the virtual WAN, grouped by hub key."
  value       = { for key, value in module.bastion_public_ip : key => value.public_ip_address }
}

output "bastion_host_public_ip_resource_ids" {
  description = "The resource IDs of the public IP addresses of the bastion hosts associated with the virtual WAN, grouped by hub key."
  value       = { for key, value in module.bastion_public_ip : key => value.resource_id }
}

output "bastion_host_resource_ids" {
  description = "The resource IDs of the bastion hosts associated with the virtual WAN, grouped by hub key."
  value       = { for key, value in module.bastion_host : key => value.resource_id }
}

output "ddos_protection_plan_resource_id" {
  description = "The resource ID of the DDoS protection plan, if enabled."
  value       = local.ddos_protection_plan_enabled ? module.ddos_protection_plan[0].resource_id : null
}

output "dns_resolver_inbound_endpoint_ip_addresses" {
  description = "The IP addresses of the inbound endpoints of the private DNS resolvers, grouped by hub key."
  value       = { for key, value in module.dns_resolver : key => value.inbound_endpoint_ips }
}

output "dns_resolver_resource_ids" {
  description = "The resource IDs of the private DNS resolvers, grouped by hub key."
  value       = { for key, value in module.dns_resolver : key => value.resource_id }
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

output "private_dns_zone_auto_registration_resource_ids" {
  description = "Resource IDs of the auto-registration private DNS zones, grouped by hub key."
  value       = { for key, value in module.private_dns_zone_auto_registration : key => value.resource_id }
}

output "nat_gateway_resource_ids" {
  description = "Resource IDs of the NAT gateways."
  value       = { for key, value in module.hub_and_spoke_vnet.nat_gateways : key => value.resource_id }
}

output "nat_gateways" {
  description = "NAT gateways for each hub virtual network."
  value       = module.hub_and_spoke_vnet.nat_gateways
}

output "private_dns_zone_resource_ids" {
  description = "Resource IDs of the private DNS zones"
  value       = { for key, value in module.private_dns_zones : key => value.private_dns_zone_resource_ids }
}

output "private_link_private_dns_zones_maps" {
  description = "Final configuration applied to the private DNS zones and associated virtual network links."
  value       = { for key, value in module.private_dns_zones : key => value.private_link_private_dns_zones_map }
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
  description = "Resource IDs of route tables associated with the gateway."
  value       = { for key, value in module.gateway_route_table : key => value.resource_id }
}

output "route_tables_user_subnets" {
  description = "Route tables associated with the user subnets."
  value       = module.hub_and_spoke_vnet.hub_route_tables_user_subnets
}

output "virtual_network_gateway_express_route_circuit_connection_resource_ids" {
  description = "Resource IDs of the ExpressRoute circuit connections created on the virtual network gateways, grouped by gateway key and then by ExpressRoute circuit connection key."
  value       = { for key, value in module.virtual_network_gateway : key => { for k, v in value.virtual_network_gateway_connections.erc : k => v.id } }
}

output "virtual_network_gateway_local_network_gateway_connection_resource_ids" {
  description = "Resource IDs of the local network gateway connections created on the virtual network gateways, grouped by gateway key and then by local network gateway connection key."
  value       = { for key, value in module.virtual_network_gateway : key => { for k, v in value.virtual_network_gateway_connections.lgw : k => v.id } }
}

output "virtual_network_gateway_local_network_gateway_resource_ids" {
  description = "Resource IDs of the local network gateways created alongside the virtual network gateways, grouped by gateway key and then by local network gateway key."
  value       = { for key, value in module.virtual_network_gateway : key => { for k, v in value.local_network_gateways : k => v.id } }
}

output "virtual_network_gateway_public_ip_addresses" {
  description = "The public IP addresses of the virtual network gateways, grouped by gateway key and then by IP configuration key."
  value       = { for key, value in module.virtual_network_gateway : key => { for k, v in value.public_ip_addresses : k => v.ip_address } }
}

output "virtual_network_gateway_public_ip_resource_ids" {
  description = "The resource IDs of the public IP addresses of the virtual network gateways, grouped by gateway key and then by IP configuration key."
  value       = { for key, value in module.virtual_network_gateway : key => { for k, v in value.public_ip_addresses : k => v.id } }
}

output "virtual_network_gateway_resource_ids" {
  description = "Resource IDs of the virtual network gateways, grouped by gateway key (e.g. `<hub_key>-express-route` and `<hub_key>-vpn`)."
  value       = { for key, value in module.virtual_network_gateway : key => value.resource_id }
}

output "virtual_network_resource_ids" {
  description = "Resource IDs of the virtual networks."
  value       = { for key, value in module.hub_and_spoke_vnet.virtual_networks : key => value.id }
}

output "virtual_network_resource_names" {
  description = "Resource names of the virtual networks."
  value       = { for key, value in module.hub_and_spoke_vnet.virtual_networks : key => value.name }
}
