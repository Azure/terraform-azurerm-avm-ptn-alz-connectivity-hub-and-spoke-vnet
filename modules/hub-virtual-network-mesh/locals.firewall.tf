locals {
  firewall_policy_id = {
    for vnet_name, policy in module.fw_policies : vnet_name => policy.resource_id
  }
}

locals {
  firewall_ip_configurations = { for vnet_key, vnet_value in local.firewall_merged_ip_configurations : vnet_key =>
    { for ip_config_key, ip_config_value in vnet_value : ip_config_key => {
      name                 = coalesce(ip_config_value.name, ip_config_key)
      public_ip_address_id = module.fw_default_ips[ip_config_value.public_ip_key].public_ip_id
      subnet_id            = ip_config_value.is_default ? module.hub_virtual_network_subnets[ip_config_value.subnet_key].resource_id : null
    } }
  }
  firewall_merged_ip_configurations = { for vnet_key, vnet_value in var.hub_virtual_networks : vnet_key =>
    length(vnet_value.firewall.ip_configurations) > 0 ?
    { for ip_config_key, ip_config_value in vnet_value.firewall.ip_configurations : ip_config_key => {
      public_ip_key                 = ip_config_key == "default" ? vnet_key : "${vnet_key}-${ip_config_key}"
      subnet_key                    = "${vnet_key}-${local.firewall_subnet_name}"
      is_default                    = ip_config_value.is_default || (alltrue([for ip_config in values(vnet_value.firewall.ip_configurations) : !ip_config.is_default]) && (length(vnet_value.firewall.ip_configurations) == 1 || ip_config_key == "default"))
      name                          = ip_config_value.name == null ? ip_config_key : ip_config_value.name
      public_ip_resource_group_name = coalesce(ip_config_value.public_ip_config.resource_group_name, local.resource_group_names[vnet_key])
      public_ip_config              = ip_config_value.public_ip_config
    } } :
    {
      default = {
        public_ip_key                 = vnet_key
        subnet_key                    = "${vnet_key}-${local.firewall_subnet_name}"
        is_default                    = true
        name                          = vnet_value.firewall.default_ip_configuration.name == null ? "default" : vnet_value.firewall.default_ip_configuration.name
        public_ip_resource_group_name = coalesce(vnet_value.firewall.default_ip_configuration.public_ip_config.resource_group_name, local.resource_group_names[vnet_key])
        public_ip_config              = vnet_value.firewall.default_ip_configuration.public_ip_config
      }
    }
  if vnet_value.firewall != null }
}


locals {
  firewalls = {
    for vnet_name, vnet in var.hub_virtual_networks : vnet_name => {
      name                  = coalesce(vnet.firewall.name, "fw-${vnet_name}")
      sku_name              = vnet.firewall.sku_name
      sku_tier              = vnet.firewall.sku_tier
      subnet_address_prefix = vnet.firewall.subnet_address_prefix
      firewall_policy_id    = try(local.firewall_policy_id[vnet_name], vnet.firewall.firewall_policy_id, null)
      resource_group_name   = coalesce(vnet.firewall.resource_group_name, local.resource_group_names[vnet_name])
      private_ip_ranges     = vnet.firewall.private_ip_ranges
      tags                  = vnet.firewall.tags
      management_ip_enabled = vnet.firewall.management_ip_enabled
      management_ip_configuration = {
        name = coalesce(vnet.firewall.management_ip_configuration.name, "defaultMgmt")
      }
      zones = vnet.firewall.zones
    } if vnet.firewall != null
  }
  fw_default_ip_configuration_pip = { for public_ip in flatten([
    for vnet_key, vnet_value in local.firewall_merged_ip_configurations : [
      for ip_config_key, ip_config_value in vnet_value : {
        composite_key       = ip_config_value.public_ip_key
        location            = var.hub_virtual_networks[vnet_key].location
        name                = coalesce(ip_config_value.public_ip_config.name, "pip-fw-${ip_config_value.public_ip_key}")
        resource_group_name = ip_config_value.public_ip_resource_group_name
        ip_version          = ip_config_value.public_ip_config.ip_version
        sku_tier            = ip_config_value.public_ip_config.sku_tier
        tags                = var.hub_virtual_networks[vnet_key].firewall.tags
        zones               = ip_config_value.public_ip_config.zones
      }
    ]
  ]) : public_ip.composite_key => public_ip }
  fw_management_ip_configuration_pip = {
    for vnet_name, vnet in var.hub_virtual_networks : vnet_name => {
      location            = vnet.location
      name                = coalesce(vnet.firewall.management_ip_configuration.public_ip_config.name, "pip-fw-mgmt-${vnet_name}")
      resource_group_name = coalesce(vnet.firewall.management_ip_configuration.public_ip_config.resource_group_name, local.resource_group_names[vnet_name])
      ip_version          = vnet.firewall.management_ip_configuration.public_ip_config.ip_version
      sku_tier            = vnet.firewall.management_ip_configuration.public_ip_config.sku_tier
      tags                = vnet.firewall.tags
      zones               = vnet.firewall.management_ip_configuration.public_ip_config.zones
    } if vnet.firewall != null && vnet.firewall.management_ip_enabled
  }
  fw_policies = {
    for vnet_name, vnet in var.hub_virtual_networks : vnet_name => {
      name                              = coalesce(vnet.firewall.firewall_policy.name, "fwp-${vnet_name}")
      location                          = coalesce(vnet.firewall.firewall_policy.location, vnet.location)
      resource_group_name               = coalesce(vnet.firewall.firewall_policy.resource_group_name, local.resource_group_names[vnet_name])
      sku                               = vnet.firewall.firewall_policy.sku
      auto_learn_private_ranges_enabled = vnet.firewall.firewall_policy.auto_learn_private_ranges_enabled
      base_policy_id                    = vnet.firewall.firewall_policy.base_policy_id
      dns                               = vnet.firewall.firewall_policy.dns
      threat_intelligence_allowlist     = vnet.firewall.firewall_policy.threat_intelligence_allowlist
      explicit_proxy                    = vnet.firewall.firewall_policy.explicit_proxy
      identity                          = vnet.firewall.firewall_policy.identity
      insights                          = vnet.firewall.firewall_policy.insights
      intrusion_detection               = vnet.firewall.firewall_policy.intrusion_detection
      private_ip_ranges                 = vnet.firewall.firewall_policy.private_ip_ranges
      sql_redirect_allowed              = vnet.firewall.firewall_policy.sql_redirect_allowed
      threat_intelligence_mode          = vnet.firewall.firewall_policy.threat_intelligence_mode
      tls_certificate                   = vnet.firewall.firewall_policy.tls_certificate
      tags                              = vnet.firewall.tags
    } if vnet.firewall != null && vnet.firewall.firewall_policy != null && vnet.firewall.firewall_policy_id == null
  }
}
