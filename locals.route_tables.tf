locals {
  gateway_route_table = { for key, value in var.hub_virtual_networks : key => {
    name                          = coalesce(value.virtual_network_gateways.route_table_name, local.default_names[key].virtual_network_gateway_route_table_name)
    location                      = value.location
    resource_group_name           = local.hub_virtual_networks_resource_group_names[key]
    bgp_route_propagation_enabled = value.virtual_network_gateways.route_table_bgp_route_propagation_enabled
    } if local.gateway_route_table_enabled[key]
  }
  gateway_route_table_custom_routes = {
    for key, value in var.hub_virtual_networks : key => {
      for key_rt, value_rt in value.virtual_network_gateways.route_table_custom_routes : key_rt => value.virtual_network_gateways.route_table_creation_enabled ? {
        name                = coalesce(value_rt.name, "${key}-${key_rt}")
        address_prefix      = value_rt.address_prefix
        next_hop_type       = coalesce(value_rt.next_hop_type, "VirtualAppliance")
        next_hop_ip_address = value_rt.next_hop_ip_address != null ? value_rt.next_hop_ip_address : local.gateway_route_table_default_route_ip_address[key]
      } : {}
    }
  }
  gateway_route_table_default_route = {
    for key, value in var.hub_virtual_networks : key => local.gateway_route_table_default_route_enabled[key] ? {
      default_route = {
        name                = coalesce(value.virtual_network_gateways.route_table_gateway_firewall_route_name, "${key}-default")
        address_prefix      = value.virtual_network_gateways.subnet_address_prefix
        next_hop_type       = "VirtualAppliance"
        next_hop_ip_address = local.gateway_route_table_default_route_ip_address[key]
      }
    } : {}
  }
  gateway_route_table_default_route_enabled    = { for key, value in var.hub_virtual_networks : key => value.virtual_network_gateways.route_table_gateway_firewall_route_enabled && value.virtual_network_gateways.route_table_creation_enabled && (local.firewall_enabled[key] || value.hub_virtual_network.hub_router_ip_address != null) }
  gateway_route_table_default_route_ip_address = { for key, value in var.hub_virtual_networks : key => local.firewall_enabled[key] ? module.hub_and_spoke_vnet.firewalls[key].private_ip_address : value.hub_virtual_network.hub_router_ip_address }
  gateway_route_table_enabled                  = { for key, value in var.hub_virtual_networks : key => (local.virtual_network_gateways_express_route_enabled[key] || local.virtual_network_gateways_vpn_enabled[key]) && value.virtual_network_gateways.route_table_creation_enabled }
  gateway_route_table_routes                   = { for key, value in var.hub_virtual_networks : key => merge(local.gateway_route_table_default_route[key], local.gateway_route_table_custom_routes[key]) }
  gateway_route_table_routes_flattened = {
    for route in
    flatten([for key, value in local.gateway_route_table_routes : [
      for route_key, route_value in value : {
        composite_key       = "${key}-${route_key}"
        hub_network_key     = key
        name                = route_value.name
        address_prefix      = route_value.address_prefix
        next_hop_type       = route_value.next_hop_type
        next_hop_ip_address = route_value.next_hop_ip_address
      }
    ]]) : route.composite_key => route
  }
}
