locals {
#   gateway_route_table_default_route = { for key, value in var.hub_virtual_networks : key => {
#     virtual_network_key    = key
#     key                    = key
#     name                   = "${key}-${replace(value.address_space, "/", "-")}"
#     address_prefix         = value.address_space
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = module.hub_and_spoke_vnet.firewalls[key].output.private_ip_address
#     }
#   }
  gateway_route_table_routes = { for key, value in var.hub_virtual_networks : key => {
    for routeKey, route in value.routes : routeKey => {
      virtual_network_key    = key
      key                    = key
      name                   = can(route.name) ? route.name : "${key}-${routeKey}-${replace(route.address_prefix, "/", "-")}"
      address_prefix         = route.address_prefix
      next_hop_type          = can(route.next_hop_type) ? route.next_hop_type : "VirtualAppliance"
      next_hop_in_ip_address = can(route.next_hop_in_ip_address) ? route.next_hop_in_ip_address : try(module.hub_and_spoke_vnet.firewalls[key].output.private_ip_address, null)
    }
    }
  }
  gateway_route_table = { for key, value in var.hub_virtual_networks : key => {
    name                          = coalesce(value.virtual_network_gateways.route_table_name, local.default_names[key].virtual_network_gateway_route_table_name)
    location                      = value.location
    resource_group_name           = local.hub_virtual_networks_resource_group_names[key]
    bgp_route_propagation_enabled = value.virtual_network_gateways.route_table_bgp_route_propagation_enabled
    routes                        = local.gateway_route_table_routes[key]
    # Assumes only assigning gw route table to one subnet in each region
    subnet_resource_ids = can(module.virtual_network_gateway.subnet.id) ? { default = try(module.virtual_network_gateway.subnet.id, null) } : {}
    } if local.gateway_route_table_enabled[key]
  }
  gateway_route_table_enabled = { for key, value in var.hub_virtual_networks : key => (local.virtual_network_gateways_express_route_enabled[key] || local.virtual_network_gateways_vpn_enabled[key]) && value.virtual_network_gateways.route_table_creation_enabled }
}
