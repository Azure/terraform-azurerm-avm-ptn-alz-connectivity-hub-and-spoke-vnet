locals {
  gateway_route_table_default_route = { for key, value in var.hub_virtual_networks : key => {
    routes = {
      default_route = {
        virtual_network_key    = key
        key                    = "default_route"
        name                   = "${key}-${replace(module.hub_and_spoke_vnet.virtual_networks[key].subnets["${key}-gateway"].address_prefixes, "/", "-")}"
        address_prefix         = module.hub_and_spoke_vnet.virtual_networks[key].subnets["${key}-gateway"].address_prefixes
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = module.hub_and_spoke_vnet.firewalls[key].private_ip_address
      }
    }
    }
  }
  gateway_route_table_routes = { for key, value in var.hub_virtual_networks : key => {
    for routeKey, route in value.virtual_network_gateways.routes : routeKey => {
      virtual_network_key    = key
      key                    = routeKey
      name                   = can(route.name) ? route.name : "${key}-${routeKey}-${replace(route.address_prefix, "/", "-")}"
      address_prefix         = route.address_prefix
      next_hop_type          = can(route.next_hop_type) ? route.next_hop_type : "VirtualAppliance"
      next_hop_in_ip_address = can(route.next_hop_in_ip_address) ? route.next_hop_in_ip_address : try(module.hub_and_spoke_vnet.firewalls[key].private_ip_address, null)
    }
    }
  }
  final_gateway_route_table_routes = merge(local.gateway_route_table_routes, local.gateway_route_table_default_route)

  gateway_route_table = { for key, value in var.hub_virtual_networks : key => {
    name                          = coalesce(value.virtual_network_gateways.route_table_name, local.default_names[key].virtual_network_gateway_route_table_name)
    location                      = value.location
    resource_group_name           = local.hub_virtual_networks_resource_group_names[key]
    bgp_route_propagation_enabled = value.virtual_network_gateways.route_table_bgp_route_propagation_enabled
    routes                        = local.final_gateway_route_table_routes[key]
    subnet_resource_ids           = can(module.hub_and_spoke_vnet.virtual_networks[key].subnets["${key}-gateway"].resource_id) ? { default = module.hub_and_spoke_vnet.virtual_networks[key].subnets["${key}-gateway"].resource_id } : {}
    # subnet_resource_ids = can(module.virtual_network_gateway.subnet.id) ? { default = try(module.virtual_network_gateway.subnet.id, null) } : {}
    } if local.gateway_route_table_enabled[key]
  }
  gateway_route_table_enabled = { for key, value in var.hub_virtual_networks : key => (local.virtual_network_gateways_express_route_enabled[key] || local.virtual_network_gateways_vpn_enabled[key]) && value.virtual_network_gateways.route_table_creation_enabled }
}
