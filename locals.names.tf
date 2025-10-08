locals {
  default_names = {
    for key, value in var.hub_virtual_networks : key => {
      for key_name, value_name in tomap(var.default_naming_convention) : key_name => templatestring(value_name, {
        location = value.location
        sequence = format(var.default_naming_convention_sequence.padding_format, var.default_naming_convention_sequence.starting_number)
      })
    }
  }
  default_names_virtual_network_gateway_express_route = {
    for key, value in var.hub_virtual_networks : key => {
      for ip_config_key, ip_config_value in value.virtual_network_gateways.express_route.ip_configurations : ip_config_key => {
        public_ip_name = templatestring(var.default_naming_convention.virtual_network_gateway_express_route_public_ip_name, {
          location = value.location
          sequence = format(var.default_naming_convention_sequence.padding_format, index(keys(value.virtual_network_gateways.express_route.ip_configurations), ip_config_key) + var.default_naming_convention_sequence.starting_number)
        })
        ip_config_name = templatestring(var.default_naming_convention.virtual_network_gateway_express_route_ip_configuration_name, {
          location = value.location
          sequence = format(var.default_naming_convention_sequence.padding_format, index(keys(value.virtual_network_gateways.express_route.ip_configurations), ip_config_key) + var.default_naming_convention_sequence.starting_number)
        })
      }
    }
  }
  default_names_virtual_network_gateway_vpn = {
    for key, value in var.hub_virtual_networks : key => {
      for ip_config_key, ip_config_value in value.virtual_network_gateways.vpn.ip_configurations : ip_config_key => {
        public_ip_name = templatestring(var.default_naming_convention.virtual_network_gateway_vpn_public_ip_name, {
          location = value.location
          sequence = format(var.default_naming_convention_sequence.padding_format, index(keys(value.virtual_network_gateways.vpn.ip_configurations), ip_config_key) + var.default_naming_convention_sequence.starting_number)
        })
        ip_config_name = templatestring(var.default_naming_convention.virtual_network_gateway_vpn_ip_configuration_name, {
          location = value.location
          sequence = format(var.default_naming_convention_sequence.padding_format, index(keys(value.virtual_network_gateways.vpn.ip_configurations), ip_config_key) + var.default_naming_convention_sequence.starting_number)
        })
      }
    }
  }
}
