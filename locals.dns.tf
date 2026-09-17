locals {
  private_dns_zones_enabled = { for key, value in local.hub_virtual_networks_by_key : key => nonsensitive(value.enabled_resources.private_dns_zones) }
  private_dns_zone_maps = {
    for hub_key, hub in local.hub_virtual_networks_by_key : hub_key => {
      for map_name in ["private_link_private_dns_zones", "private_link_private_dns_zones_additional"] : map_name => nonsensitive(hub.private_dns_zones[map_name] == null) ? null : {
        for zone_key in nonsensitive(keys(hub.private_dns_zones[map_name])) : zone_key => {
          zone_name                              = nonsensitive(hub.private_dns_zones[map_name][zone_key].zone_name)
          private_dns_zone_supports_private_link = nonsensitive(hub.private_dns_zones[map_name][zone_key].private_dns_zone_supports_private_link)
          resolution_policy                      = nonsensitive(hub.private_dns_zones[map_name][zone_key].resolution_policy == null) ? null : hub.private_dns_zones[map_name][zone_key].resolution_policy
          custom_iterator = nonsensitive(hub.private_dns_zones[map_name][zone_key].custom_iterator == null) ? null : {
            replacement_placeholder = nonsensitive(hub.private_dns_zones[map_name][zone_key].custom_iterator.replacement_placeholder)
            replacement_values = {
              for iterator_key in nonsensitive(keys(hub.private_dns_zones[map_name][zone_key].custom_iterator.replacement_values)) : iterator_key => nonsensitive(hub.private_dns_zones[map_name][zone_key].custom_iterator.replacement_values[iterator_key])
            }
          }
        }
      }
    }
  }
  private_dns_link_maps = {
    for hub_key, hub in local.hub_virtual_networks_by_key : hub_key => {
      for map_name in ["virtual_network_link_default_virtual_networks", "virtual_network_link_additional_virtual_networks", "virtual_network_link_overrides_by_virtual_network", "virtual_network_link_overrides_by_zone"] : map_name => nonsensitive(hub.private_dns_zones[map_name] == null) ? null : {
        for link_key in nonsensitive(keys(hub.private_dns_zones[map_name])) : link_key => {
          for attribute in nonsensitive(keys(hub.private_dns_zones[map_name][link_key])) : attribute => {
            public   = nonsensitive(hub.private_dns_zones[map_name][link_key][attribute])
            original = hub.private_dns_zones[map_name][link_key][attribute]
          }[nonsensitive(contains(["enabled", "virtual_network_resource_id", "virtual_network_link_name_template_override", "name"], attribute) || hub.private_dns_zones[map_name][link_key][attribute] == null) ? "public" : "original"]
        }
      }
    }
  }
  private_dns_nested_link_maps = {
    for hub_key, hub in local.hub_virtual_networks_by_key : hub_key => {
      for map_name in ["virtual_network_link_by_zone_and_virtual_network", "virtual_network_link_overrides_by_zone_and_virtual_network"] : map_name => nonsensitive(hub.private_dns_zones[map_name] == null) ? null : {
        for zone_key in nonsensitive(keys(hub.private_dns_zones[map_name])) : zone_key => {
          for link_key in nonsensitive(keys(hub.private_dns_zones[map_name][zone_key])) : link_key => {
            for attribute in nonsensitive(keys(hub.private_dns_zones[map_name][zone_key][link_key])) : attribute => {
              public   = nonsensitive(hub.private_dns_zones[map_name][zone_key][link_key][attribute])
              original = hub.private_dns_zones[map_name][zone_key][link_key][attribute]
            }[nonsensitive(contains(["enabled", "virtual_network_resource_id", "virtual_network_link_name_template_override", "name"], attribute) || hub.private_dns_zones[map_name][zone_key][link_key][attribute] == null) ? "public" : "original"]
          }
        }
      }
    }
  }
}

locals {
  private_dns_zones = { for key, value in local.hub_virtual_networks_by_key : key => {
    location  = nonsensitive(value.location)
    parent_id = coalesce(value.private_dns_zones.parent_id, value.hub_virtual_network.parent_id, value.default_parent_id)
    private_link_private_dns_zones_regex_filter = nonsensitive(value.private_dns_zones.private_link_private_dns_zones_regex_filter == null) ? {
      enabled      = key != local.primary_region_key
      regex_filter = "{regionName}|{regionCode}"
      } : {
      enabled      = nonsensitive(value.private_dns_zones.private_link_private_dns_zones_regex_filter.enabled)
      regex_filter = nonsensitive(value.private_dns_zones.private_link_private_dns_zones_regex_filter.regex_filter)
    }
    private_link_excluded_zones                                = nonsensitive(value.private_dns_zones.private_link_excluded_zones)
    private_link_private_dns_zones                             = local.private_dns_zone_maps[key].private_link_private_dns_zones
    private_link_private_dns_zones_additional                  = local.private_dns_zone_maps[key].private_link_private_dns_zones_additional
    virtual_network_link_default_virtual_networks              = nonsensitive(local.private_dns_link_maps[key].virtual_network_link_default_virtual_networks == null) ? local.private_dns_zones_virtual_network_link_default_virtual_networks : local.private_dns_link_maps[key].virtual_network_link_default_virtual_networks
    virtual_network_link_additional_virtual_networks           = local.private_dns_link_maps[key].virtual_network_link_additional_virtual_networks
    virtual_network_link_by_zone_and_virtual_network           = local.private_dns_nested_link_maps[key].virtual_network_link_by_zone_and_virtual_network
    virtual_network_link_overrides_by_virtual_network          = local.private_dns_link_maps[key].virtual_network_link_overrides_by_virtual_network
    virtual_network_link_overrides_by_zone                     = local.private_dns_link_maps[key].virtual_network_link_overrides_by_zone
    virtual_network_link_overrides_by_zone_and_virtual_network = local.private_dns_nested_link_maps[key].virtual_network_link_overrides_by_zone_and_virtual_network
    virtual_network_link_name_template                         = nonsensitive(value.private_dns_zones.virtual_network_link_name_template)
    virtual_network_link_resolution_policy_default             = nonsensitive(value.private_dns_zones.virtual_network_link_resolution_policy_default == null) ? null : value.private_dns_zones.virtual_network_link_resolution_policy_default
    tags                                                       = nonsensitive(value.private_dns_zones.tags == null) ? (nonsensitive(var.tags == null) ? {} : var.tags) : { for tag_key in nonsensitive(keys(value.private_dns_zones.tags)) : tag_key => value.private_dns_zones.tags[tag_key] }
    lock = value.private_dns_zones.lock == null ? null : {
      kind = value.private_dns_zones.lock.kind
      name = coalesce(value.private_dns_zones.lock.name, "lock-${key}-private-dns-zones-${value.private_dns_zones.lock.kind}")
    }
  } if local.private_dns_zones_enabled[key] }
  private_dns_zones_auto_registration = { for key, value in local.hub_virtual_networks_by_key : key => {
    location    = value.location
    domain_name = coalesce(value.private_dns_zones.auto_registration_zone_name, "${value.location}.azure.local")
    parent_id   = coalesce(value.private_dns_zones.auto_registration_zone_parent_id, value.private_dns_zones.parent_id, value.hub_virtual_network.parent_id, value.default_parent_id)
    tags        = coalesce(value.private_dns_zones.tags, var.tags, {})
    virtual_network_links = {
      auto_registration = {
        name                 = "vnet-link-${key}-auto-registration"
        virtual_network_id   = module.hub_and_spoke_vnet.virtual_networks[key].id
        registration_enabled = true
        tags                 = coalesce(value.private_dns_zones.tags, var.tags, {})
      }
    }
  } if local.private_dns_zones_enabled[key] && nonsensitive(value.private_dns_zones.auto_registration_zone_enabled) }
  private_dns_zones_virtual_network_link_default_virtual_networks = {
    for key, value in module.hub_and_spoke_vnet.virtual_networks : key => {
      virtual_network_resource_id                 = value.id
      virtual_network_link_name_template_override = nonsensitive(var.hub_virtual_networks[key].private_dns_zones.virtual_network_link_name_template)
      resolution_policy                           = nonsensitive(var.hub_virtual_networks[key].private_dns_zones.virtual_network_link_resolution_policy_default == null) ? null : var.hub_virtual_networks[key].private_dns_zones.virtual_network_link_resolution_policy_default
    }
  }
}
