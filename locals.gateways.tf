locals {
  virtual_network_gateways = merge(local.virtual_network_gateways_express_route, local.virtual_network_gateways_vpn)
  virtual_network_gateways_express_route = {
    for hub_network_key, hub_network_value in var.hub_virtual_networks : "${hub_network_key}-express-route" => {
      virtual_network_gateway_subnet_id = module.hub_and_spoke_vnet.virtual_networks[hub_network_key].subnets["${hub_network_key}-gateway"].resource_id
      parent_id                         = coalesce(hub_network_value.virtual_network_gateways.express_route.parent_id, hub_network_value.hub_virtual_network.parent_id)
      tags                              = coalesce(hub_network_value.virtual_network_gateways.express_route.tags, var.tags, {})
      virtual_network_gateway = merge({
        location = hub_network_value.hub_virtual_network.location
        type     = "ExpressRoute"
      }, hub_network_value.virtual_network_gateways.express_route)
    } if local.virtual_network_gateways_express_route_enabled[hub_network_key]
  }
  virtual_network_gateways_express_route_enabled = {
    for hub_network_key, hub_network_value in var.hub_virtual_networks : hub_network_key => hub_network_value.virtual_network_gateways.express_route.enabled
  }
  virtual_network_gateways_vpn = {
    for hub_network_key, hub_network_value in var.hub_virtual_networks : "${hub_network_key}-vpn" => {
      virtual_network_gateway_subnet_id = module.hub_and_spoke_vnet.virtual_networks[hub_network_key].subnets["${hub_network_key}-gateway"].resource_id
      parent_id                         = coalesce(hub_network_value.virtual_network_gateways.vpn.parent_id, hub_network_value.hub_virtual_network.parent_id)
      tags                              = coalesce(hub_network_value.virtual_network_gateways.vpn.tags, var.tags, {})
      virtual_network_gateway = merge({
        location = hub_network_value.hub_virtual_network.location
        type     = "Vpn"
      }, hub_network_value.virtual_network_gateways.vpn)
    } if local.virtual_network_gateways_vpn_enabled[hub_network_key]
  }
  virtual_network_gateways_vpn_enabled = {
    for hub_network_key, hub_network_value in var.hub_virtual_networks : hub_network_key => hub_network_value.virtual_network_gateways.vpn.enabled
  }
}
