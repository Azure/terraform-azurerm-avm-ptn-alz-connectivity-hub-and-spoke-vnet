locals {
  virtual_network_gateways = merge(local.virtual_network_gateways_express_route, local.virtual_network_gateways_vpn)
  virtual_network_gateways_express_route = {
    for hub_network_key, hub_network_value in var.hub_virtual_networks : "${hub_network_key}-express-route" => {
      name                              = coalesce(hub_network_value.virtual_network_gateways.express_route.name, local.default_names[hub_network_key].virtual_network_gateway_express_route_name)
      virtual_network_gateway_subnet_id = module.hub_and_spoke_vnet.virtual_networks[hub_network_key].subnets["${hub_network_key}-gateway"].resource_id
      parent_id                         = coalesce(hub_network_value.virtual_network_gateways.express_route.parent_id, hub_network_value.hub_virtual_network.parent_id, hub_network_value.default_parent_id)
      tags                              = coalesce(hub_network_value.virtual_network_gateways.express_route.tags, var.tags, {})
      ip_configurations                 = local.virtual_network_gateways_express_route_ip_configurations[hub_network_key]
      sku                               = coalesce(hub_network_value.virtual_network_gateways.express_route.sku, length(local.availability_zones[hub_network_key]) == 0 ? "Standard" : "ErGw1AZ")
      virtual_network_gateway = merge({
        location = hub_network_value.location
        type     = "ExpressRoute"
      }, hub_network_value.virtual_network_gateways.express_route)
    } if local.virtual_network_gateways_express_route_enabled[hub_network_key]
  }
  virtual_network_gateways_express_route_enabled = {
    for hub_network_key, hub_network_value in var.hub_virtual_networks : hub_network_key => hub_network_value.enabled_resources.virtual_network_gateway_express_route
  }
  virtual_network_gateways_express_route_ip_configurations = {
    for key, value in var.hub_virtual_networks : key => {
      for ip_config_key, ip_config_value in value.virtual_network_gateways.express_route.ip_configurations : ip_config_key => merge(ip_config_value, {
        name = coalesce(ip_config_value.name, local.default_names_virtual_network_gateway_express_route[key][ip_config_key].ip_config_name)
        public_ip = merge(ip_config_value.public_ip, {
          name  = coalesce(ip_config_value.public_ip.name, local.default_names_virtual_network_gateway_express_route[key][ip_config_key].public_ip_name)
          zones = coalesce(ip_config_value.public_ip.zones, local.availability_zones[key])
        })
      })
    }
  }
}

locals {
  virtual_network_gateways_vpn = {
    for hub_network_key, hub_network_value in var.hub_virtual_networks : "${hub_network_key}-vpn" => {
      name                              = coalesce(hub_network_value.virtual_network_gateways.vpn.name, local.default_names[hub_network_key].virtual_network_gateway_vpn_name)
      virtual_network_gateway_subnet_id = module.hub_and_spoke_vnet.virtual_networks[hub_network_key].subnets["${hub_network_key}-gateway"].resource_id
      parent_id                         = coalesce(hub_network_value.virtual_network_gateways.vpn.parent_id, hub_network_value.hub_virtual_network.parent_id, hub_network_value.default_parent_id)
      tags                              = coalesce(hub_network_value.virtual_network_gateways.vpn.tags, var.tags, {})
      ip_configurations                 = local.virtual_network_gateways_vpn_ip_configurations[hub_network_key]
      sku                               = hub_network_value.virtual_network_gateways.vpn.sku
      virtual_network_gateway = merge({
        location = hub_network_value.location
        type     = "Vpn"
      }, hub_network_value.virtual_network_gateways.vpn)
    } if local.virtual_network_gateways_vpn_enabled[hub_network_key]
  }
  virtual_network_gateways_vpn_enabled = {
    for hub_network_key, hub_network_value in var.hub_virtual_networks : hub_network_key => hub_network_value.enabled_resources.virtual_network_gateway_vpn
  }
  virtual_network_gateways_vpn_ip_configurations = {
    for key, value in var.hub_virtual_networks : key => {
      for ip_config_key, ip_config_value in value.virtual_network_gateways.vpn.ip_configurations : ip_config_key => merge(ip_config_value, {
        name = coalesce(ip_config_value.name, local.default_names_virtual_network_gateway_vpn[key][ip_config_key].ip_config_name)
        public_ip = merge(ip_config_value.public_ip, {
          name  = coalesce(ip_config_value.public_ip.name, local.default_names_virtual_network_gateway_vpn[key][ip_config_key].public_ip_name)
          zones = coalesce(ip_config_value.public_ip.zones, local.availability_zones[key])
        })
      })
    }
  }
}
