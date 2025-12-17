locals {
  # Merge sensitive values into hub_virtual_networks for gateways
  hub_virtual_networks_with_sensitive = {
    for key, value in var.hub_virtual_networks : key => merge(value, {
      virtual_network_gateways = merge(value.virtual_network_gateways, {
        express_route = merge(value.virtual_network_gateways.express_route, {
          express_route_circuits = {
            for circuit_key, circuit_value in coalesce(value.virtual_network_gateways.express_route.express_route_circuits, {}) : circuit_key => merge(circuit_value, {
              connection = circuit_value.connection != null ? merge(circuit_value.connection, {
                shared_key = try(var.hub_virtual_networks_sensitive[key].virtual_network_gateways.express_route.express_route_circuits[circuit_key].connection.shared_key, circuit_value.connection.shared_key)
              }) : null
              peering = circuit_value.peering != null ? merge(circuit_value.peering, {
                shared_key = try(var.hub_virtual_networks_sensitive[key].virtual_network_gateways.express_route.express_route_circuits[circuit_key].peering.shared_key, circuit_value.peering.shared_key)
              }) : null
            })
          }
        })
        vpn = merge(value.virtual_network_gateways.vpn, {
          local_network_gateways = {
            for lgw_key, lgw_value in coalesce(value.virtual_network_gateways.vpn.local_network_gateways, {}) : lgw_key => merge(lgw_value, {
              connection = lgw_value.connection != null ? merge(lgw_value.connection, {
                shared_key = try(var.hub_virtual_networks_sensitive[key].virtual_network_gateways.vpn.local_network_gateways[lgw_key].connection.shared_key, lgw_value.connection.shared_key)
              }) : null
            })
          }
        })
      })
    })
  }

  virtual_network_gateways = merge(local.virtual_network_gateways_express_route, local.virtual_network_gateways_vpn)
  virtual_network_gateways_express_route = {
    for hub_network_key, hub_network_value in local.hub_virtual_networks_with_sensitive : "${hub_network_key}-express-route" => {
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
    for hub_network_key, hub_network_value in local.hub_virtual_networks_with_sensitive : hub_network_key => hub_network_value.enabled_resources.virtual_network_gateway_express_route
  }
  virtual_network_gateways_express_route_ip_configurations = {
    for key, value in local.hub_virtual_networks_with_sensitive : key => {
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
    for hub_network_key, hub_network_value in local.hub_virtual_networks_with_sensitive : "${hub_network_key}-vpn" => {
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
    for hub_network_key, hub_network_value in local.hub_virtual_networks_with_sensitive : hub_network_key => hub_network_value.enabled_resources.virtual_network_gateway_vpn
  }
  virtual_network_gateways_vpn_ip_configurations = {
    for key, value in local.hub_virtual_networks_with_sensitive : key => {
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
