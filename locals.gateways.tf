locals {
  resource_group_resource_type = "Microsoft.Resources/resourceGroups"
  virtual_network_gateways     = merge(local.virtual_network_gateways_express_route, local.virtual_network_gateways_vpn)
  virtual_network_gateways_express_route = {
    for hub_network_key, hub_network_value in var.hub_virtual_networks : "${hub_network_key}-express-route" => {
      virtual_network_gateway_subnet_id = module.hub_and_spoke_vnet.virtual_networks[hub_network_key].subnets["${hub_network_key}-gateway"].resource_id
      virtual_network_gateway = merge({
        parent_id       = try(hub_network_value.virtual_network_gateways.express_route.parent_id, provider::azapi::subscription_resource_id(data.azapi_client_config.current.subscription_id, local.resource_group_resource_type, [hub_network_value.hub_virtual_network.resource_group_name]))
        hub_network_key = hub_network_key
        type            = "ExpressRoute"
      }, hub_network_value.virtual_network_gateways.express_route)
    } if local.virtual_network_gateways_express_route_enabled[hub_network_key]
  }
  virtual_network_gateways_express_route_enabled = {
    for hub_network_key, hub_network_value in var.hub_virtual_networks : hub_network_key => try(hub_network_value.virtual_network_gateways.express_route.enabled, try(hub_network_value.virtual_network_gateways.express_route, null) != null)
  }
  virtual_network_gateways_vpn = {
    for hub_network_key, hub_network_value in var.hub_virtual_networks : "${hub_network_key}-vpn" => {
      virtual_network_gateway_subnet_id = module.hub_and_spoke_vnet.virtual_networks[hub_network_key].subnets["${hub_network_key}-gateway"].resource_id
      virtual_network_gateway = merge({
        parent_id       = try(hub_network_value.virtual_network_gateways.vpn.parent_id, provider::azapi::subscription_resource_id(data.azapi_client_config.current.subscription_id, local.resource_group_resource_type, [hub_network_value.hub_virtual_network.resource_group_name]))
        hub_network_key = hub_network_key
        type            = "Vpn"
      }, hub_network_value.virtual_network_gateways.vpn)
    } if local.virtual_network_gateways_vpn_enabled[hub_network_key]
  }
  virtual_network_gateways_vpn_enabled = {
    for hub_network_key, hub_network_value in var.hub_virtual_networks : hub_network_key => try(hub_network_value.virtual_network_gateways.vpn.enabled, try(hub_network_value.virtual_network_gateways.vpn, null) != null)
  }
}
