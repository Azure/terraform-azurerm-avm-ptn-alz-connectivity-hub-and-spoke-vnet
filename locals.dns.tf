locals {
  private_dns_zones_enabled = { for key, value in var.hub_virtual_networks : key => value.enabled_resources.private_dns_zones }
}

locals {
  private_dns_zones = { for key, value in var.hub_virtual_networks : key => {
    location  = value.location
    parent_id = coalesce(value.private_dns_zones.parent_id, value.hub_virtual_network.parent_id, value.default_parent_id)
    private_link_private_dns_zones_regex_filter = value.private_dns_zones.private_link_private_dns_zones_regex_filter != null ? value.private_dns_zones.private_link_private_dns_zones_regex_filter : {
      enabled = key != local.primary_region_key
    }
    private_dns_settings = value.private_dns_zones
    virtual_network_link_overrides = try(length(value.private_dns_zones.virtual_network_link_overrides), 0) > 0 ? {
      (key) = try(value.private_dns_zones.virtual_network_link_overrides, null)
    } : {}
    tags = coalesce(value.private_dns_zones.tags, var.tags, {})
  } if local.private_dns_zones_enabled[key] }
  private_dns_zones_auto_registration = { for key, value in var.hub_virtual_networks : key => {
    location    = value.location
    domain_name = coalesce(value.private_dns_zones.auto_registration_zone_name, "${value.location}.azure.local")
    parent_id   = coalesce(value.private_dns_zones.auto_registration_zone_parent_id, value.hub_virtual_network.parent_id, value.default_parent_id)
    virtual_network_links = {
      auto_registration = {
        name                 = "vnet-link-${key}-auto-registration"
        virtual_network_id   = module.hub_and_spoke_vnet.virtual_networks[key].id
        registration_enabled = true
        tags                 = var.tags
      }
    }
  } if local.private_dns_zones_enabled[key] && value.private_dns_zones.auto_registration_zone_enabled }
  private_dns_zones_virtual_network_links = {
    for key, value in module.hub_and_spoke_vnet.virtual_networks : key => {
      virtual_network_resource_id                 = value.id
      virtual_network_link_name_template_override = var.hub_virtual_networks[key].private_dns_zones.private_dns_zone_network_link_name_template
    }
  }
}
