locals {
  firewall_default_ip_configuration = {
    for key, value in var.hub_virtual_networks : key => merge(value.firewall.default_ip_configuration, {
      name = coalesce(value.firewall.default_ip_configuration.name, "default")
      public_ip_config = merge(value.firewall.default_ip_configuration.public_ip_config, {
        name  = coalesce(value.firewall.default_ip_configuration.public_ip_config.name, local.default_names[key].firewall_public_ip_name)
        zones = coalesce(value.firewall.default_ip_configuration.public_ip_config.zones, local.availability_zones[key])
      })
    })
  }
  firewall_enabled = { for key, value in var.hub_virtual_networks : key => value.enabled_resources.firewall }
  firewall_ip_configurations = {
    for key, value in var.hub_virtual_networks : key => merge(value.firewall.ip_configurations, {
      for ip_config_key, ip_config_value in value.firewall.ip_configurations : ip_config_key => merge(ip_config_value, {
        name = coalesce(ip_config_value.name, "ipconfig-fw-hub-${value.location}-${ip_config_key}")
        public_ip_config = merge(ip_config_value.public_ip_config, {
          name  = coalesce(ip_config_value.public_ip_config.name, "pip-fw-hub-${value.location}-${ip_config_key}")
          zones = coalesce(ip_config_value.public_ip_config.zones, local.availability_zones[key])
        })
      })
    })
  }
  firewall_management_ip_configuration = {
    for key, value in var.hub_virtual_networks : key => merge(value.firewall.management_ip_configuration, {
      name = coalesce(value.firewall.management_ip_configuration.name, "defaultMgmt")
      public_ip_config = merge(value.firewall.management_ip_configuration.public_ip_config, {
        name  = coalesce(value.firewall.management_ip_configuration.public_ip_config.name, local.default_names[key].firewall_management_public_ip_name)
        zones = coalesce(value.firewall.management_ip_configuration.public_ip_config.zones, local.availability_zones[key])
      })
    })
  }
  firewall_policies = { for key, value in var.hub_virtual_networks : key => local.firewall_enabled[key] ? merge(value.firewall_policy, {
    name = coalesce(value.firewall_policy.name, local.default_names[key].firewall_policy_name)
    dns  = value.firewall_policy.dns != null ? value.firewall_policy.dns : local.firewall_policy_dns_defaults[key]
  }) : null }
  firewall_policy_dns_defaults = { for key, value in var.hub_virtual_networks : key => local.private_dns_resolver_enabled[key] && local.private_dns_zones_enabled[key] && local.firewall_enabled[key] && !local.firewall_sku_is_basic[key] && value.private_dns_resolver.default_inbound_endpoint_enabled ? {
    proxy_enabled = true
    servers       = [local.private_dns_resolver_ip_addresses[key]]
  } : null }
  firewall_sku_is_basic = { for key, value in var.hub_virtual_networks : key => local.firewall_enabled[key] && (value.firewall.sku_tier == "Basic" || value.firewall_policy.sku == "Basic") }
  firewalls = { for key, value in var.hub_virtual_networks : key => local.firewall_enabled[key] ? merge(value.firewall, {
    name                             = coalesce(value.firewall.name, local.default_names[key].firewall_name)
    firewall_policy                  = local.firewall_policies[key]
    subnet_address_prefix            = coalesce(value.firewall.subnet_address_prefix, local.virtual_network_subnet_default_ip_prefixes[key]["firewall"])
    management_subnet_address_prefix = coalesce(value.firewall.management_subnet_address_prefix, local.virtual_network_subnet_default_ip_prefixes[key]["firewall_management"])
    default_ip_configuration         = local.firewall_default_ip_configuration[key]
    management_ip_configuration      = local.firewall_management_ip_configuration[key]
    ip_configurations                = local.firewall_ip_configurations[key]
    tags                             = coalesce(value.firewall.tags, var.tags, {})
    zones                            = coalesce(value.firewall.zones, local.availability_zones[key])
  }) : null }
}
