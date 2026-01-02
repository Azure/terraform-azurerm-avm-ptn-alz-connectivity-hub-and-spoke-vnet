locals {
  gateway_route_table_default_route = { for key, value in var.hub_virtual_networks : key => {
    default_fw_route = {
      name                   = "${key}-${replace(module.hub_and_spoke_vnet.virtual_networks[key].subnets["${key}-gateway"].address_prefixes, "/", "-")}"
      address_prefix         = module.hub_and_spoke_vnet.virtual_networks[key].subnets["${key}-gateway"].address_prefixes
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = module.hub_and_spoke_vnet.firewalls[key].private_ip_address
    }
    }
  }

  gateway_route_table_routes = { for key, value in var.hub_virtual_networks : key => {
    for routeKey, route in value.virtual_network_gateways.routes : routeKey => {
      name                   = try(route.name != null, false) ? route.name : "${key}-${routeKey}-${replace(route.address_prefix, "/", "-")}"
      address_prefix         = route.address_prefix
      next_hop_type          = try(route.next_hop_type != null, false) ? route.next_hop_type : "VirtualAppliance"
      next_hop_in_ip_address = try(route.next_hop_in_ip_address != null, false) ? route.next_hop_in_ip_address : try(module.hub_and_spoke_vnet.firewalls[key].private_ip_address, null)
    }
    }
  }

  #   gateway_route_table_default_route = { for key, value in var.hub_virtual_networks : key => {
  #         routes = {
  #         default_route = {
  #             virtual_network_key    = key
  #             name                   = "${key}-${replace(module.hub_and_spoke_vnet.virtual_networks[key].subnets["${key}-gateway"].address_prefixes, "/", "-")}"
  #             address_prefix         = module.hub_and_spoke_vnet.virtual_networks[key].subnets["${key}-gateway"].address_prefixes
  #             next_hop_type          = "VirtualAppliance"
  #             next_hop_in_ip_address = module.hub_and_spoke_vnet.firewalls[key].private_ip_address
  #         }
  #     }
  #   }

  #   gateway_route_table_routes = {
  #     for route in flatten([
  #       for k_src, v_src in var.hub_virtual_networks : [
  #         for route_table_entry in v_src.virtual_network_gateways.routes : {
  #           virtual_network_key    = k_src
  #           key                    = can(route_table_entry.next_hop_in_ip_address) ? "${k_src}"
  #           name                   = can(route_table_entry.name) ? route_table_entry.name : "${k_src}-${replace(route_table_entry.address_prefix, "/", "-")}"
  #           address_prefix         = route_table_entry.address_prefix
  #           next_hop_type          = can(route_table_entry.next_hop_type) ? route_table_entry.next_hop_type : "VirtualAppliance"
  #           next_hop_in_ip_address = can(route_table_entry.next_hop_in_ip_address) ? route_table_entry.next_hop_in_ip_address : try(module.hub_and_spoke_vnet.firewalls[k_src].private_ip_address, null)
  #           resource_group_name    = local.hub_virtual_networks_resource_group_names[k_src]
  #         }
  #       ]
  #     ]) : route.key => route
  #   }

  gateway_route_table = { for key, value in var.hub_virtual_networks : key => {
    name                          = coalesce(value.virtual_network_gateways.route_table_name, local.default_names[key].virtual_network_gateway_route_table_name)
    location                      = value.location
    resource_group_name           = local.hub_virtual_networks_resource_group_names[key]
    bgp_route_propagation_enabled = value.virtual_network_gateways.route_table_bgp_route_propagation_enabled
    routes                        = merge(local.gateway_route_table_routes[key], local.gateway_route_table_default_route[key])
    # subnet_resource_ids           = can(module.hub_and_spoke_vnet.virtual_networks[key].subnets["${key}-gateway"].resource_id) ? { gw-subnet = module.hub_and_spoke_vnet.virtual_networks[key].subnets["${key}-gateway"].resource_id } : {}
    subnet_resource_ids = can(module.virtual_network_gateway.subnet.id) ? { gw-subnet = module.virtual_network_gateway.subnet.id } : {}
    } if local.gateway_route_table_enabled[key]
  }
  gateway_route_table_enabled = { for key, value in var.hub_virtual_networks : key => (local.virtual_network_gateways_express_route_enabled[key] || local.virtual_network_gateways_vpn_enabled[key]) && value.virtual_network_gateways.route_table_creation_enabled }
}
