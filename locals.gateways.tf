locals {
  virtual_network_gateways = merge(local.virtual_network_gateways_express_route, local.virtual_network_gateways_vpn)
  virtual_network_gateways_express_route = {
    for hub_network_key, hub_network_value in var.hub_virtual_networks : "${hub_network_key}-express-route" => {
      hub_network_key = hub_network_key
      virtual_network_gateway = merge({
        type = "ExpressRoute"
      }, hub_network_value.virtual_network_gateways.express_route)
    } if local.virtual_network_gateways_express_route_enabled[hub_network_key]
  }
  virtual_network_gateways_express_route_enabled = {
    for hub_network_key, hub_network_value in var.hub_virtual_networks : hub_network_key => try(hub_network_value.virtual_network_gateways.express_route.enabled, try(hub_network_value.virtual_network_gateways.express_route, null) != null)
  }
  virtual_network_gateways_vpn = {
    for hub_network_key, hub_network_value in var.hub_virtual_networks : "${hub_network_key}-vpn" => {
      hub_network_key = hub_network_key
      virtual_network_gateway = merge({
        type = "Vpn"
      }, hub_network_value.virtual_network_gateways.vpn)
    } if local.virtual_network_gateways_vpn_enabled[hub_network_key]
  }
  virtual_network_gateways_vpn_enabled = {
    for hub_network_key, hub_network_value in var.hub_virtual_networks : hub_network_key => try(hub_network_value.virtual_network_gateways.vpn.enabled, try(hub_network_value.virtual_network_gateways.vpn, null) != null)
  }
}
