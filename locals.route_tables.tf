locals {
  gateway_route_table = { for key, value in var.hub_virtual_networks : key => {
    name                          = coalesce(value.virtual_network_gateways.route_table_name, local.default_names[key].virtual_network_gateway_route_table_name)
    location                      = value.location
    resource_group_name           = local.hub_virtual_networks_resource_group_names[key]
    bgp_route_propagation_enabled = value.virtual_network_gateways.route_table_bgp_route_propagation_enabled
    # routes                        = length(local.gateway_route_table_default_route) == 0 ? can(value.gateway_route_table_custom_routes.routes) ? local.gateway_route_table_custom_routes[key] : {} : merge(local.gateway_route_table_custom_routes[key], local.gateway_route_table_default_route[key])
    } if local.gateway_route_table_enabled[key]
  }
  gateway_route_table_enabled = { for key, value in var.hub_virtual_networks : key => (local.virtual_network_gateways_express_route_enabled[key] || local.virtual_network_gateways_vpn_enabled[key]) && value.virtual_network_gateways.route_table_creation_enabled }
  #   gateway_route_table_default_route = { for key, value in var.hub_virtual_networks : key => {
  #     route-gw-fw = {
  #       name                   = "${key}-${replace(value.virtual_network_gateways.subnet_address_prefix, "/", "-")}"
  #       address_prefix         = value.virtual_network_gateways.subnet_address_prefix
  #       next_hop_type          = "VirtualAppliance"
  #       next_hop_in_ip_address = try(module.hub_and_spoke_vnet.firewalls[key].private_ip_address, null)
  #     }
  #     } if value.virtual_network_gateways.route_table_gateway_firewall_route_enabled
  #   }
  gateway_route_table_default_route = { for key, value in var.hub_virtual_networks : "${key}-route-gw-fw" => {
    virtual_network_key    = key
    key                    = "${key}-route-gw-fw"
    resource_group_name    = local.hub_virtual_networks_resource_group_names[key]
    name                   = "${key}-${replace(value.virtual_network_gateways.subnet_address_prefix, "/", "-")}"
    address_prefix         = value.virtual_network_gateways.subnet_address_prefix
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = try(module.hub_and_spoke_vnet.firewalls[key].private_ip_address, null)
    } if value.virtual_network_gateways.route_table_gateway_firewall_route_enabled
  }
  #   gateway_route_table_custom_routes = { for key, value in var.hub_virtual_networks : key => {
  #     for routeKey, route in value.virtual_network_gateways.routes : routeKey => {
  #       name                   = try(route.name, null) != null ? route.name : "${key}-${routeKey}-${replace(route.address_prefix, "/", "-")}"
  #       address_prefix         = route.address_prefix
  #       next_hop_type          = try(route.next_hop_type, null) != null ? route.next_hop_type : "VirtualAppliance"
  #       next_hop_in_ip_address = try(route.next_hop_in_ip_address, null) != null ? route.next_hop_in_ip_address : try(module.hub_and_spoke_vnet.firewalls[key].private_ip_address, null)
  #     }
  #     } if can(value.virtual_network_gateways.routes)
  #   }
  gateway_route_table_custom_routes = {
    for route in flatten([
      for key, value in var.hub_virtual_networks : [
        for key_rt, value_rt in value.virtual_network_gateways.routes : {
          virtual_network_key    = key
          key                    = key_rt
          resource_group_name    = local.hub_virtual_networks_resource_group_names[key]
          name                   = try(value_rt.name, null) != null ? value_rt.name : "${key}-${key_rt}-${replace(value_rt.address_prefix, "/", "-")}"
          address_prefix         = value_rt.address_prefix
          next_hop_type          = try(value_rt.next_hop_type, null) != null ? value_rt.next_hop_type : "VirtualAppliance"
          next_hop_in_ip_address = try(value_rt.next_hop_in_ip_address, null) != null ? value_rt.next_hop_in_ip_address : try(module.hub_and_spoke_vnet.firewalls[key].private_ip_address, null)
        }
      ]
    ]) : route.key => route if local.gateway_route_table_enabled[route.key]
  }
  gateway_route_table_routes = merge(local.gateway_route_table_custom_routes, local.gateway_route_table_default_route)
}
