locals {
  private_dns_zones_enabled = { for key, value in var.hub_virtual_networks : key => try(value.private_dns_zones.enabled, try(value.private_dns_zones, null) != null) }
}

locals {
  private_dns_zones = { for key, value in var.hub_virtual_networks : key => {
    location                                    = value.hub_virtual_network.location
    resource_group_name                         = local.hub_virtual_networks_resource_group_names[key]
    private_link_excluded_zones                 = value.private_dns_zones.private_link_excluded_zones
    private_link_private_dns_zones              = value.private_dns_zones.private_link_private_dns_zones
    private_link_private_dns_zones_additional   = value.private_dns_zones.private_link_private_dns_zones_additional
    private_link_private_dns_zones_regex_filter = value.private_dns_zones.private_link_private_dns_zones_regex_filter
    tags                                        = coalesce(value.private_dns_zones.tags, var.tags)
  } if local.private_dns_zones_enabled[key] }
  private_dns_zones_auto_registration = { for key, value in var.hub_virtual_networks : key => {
    location            = value.hub_virtual_network.location
    domain_name         = value.private_dns_zones.auto_registration_zone_name
    resource_group_name = try(value.auto_registration_zone_resource_group_name, local.private_dns_zones[key].resource_group_name)
    virtual_network_links = {
      auto_registration = {
        vnetlinkname     = "vnet-link-${key}-auto-registration"
        vnetid           = module.hub_and_spoke_vnet.virtual_networks[key].id
        autoregistration = true
        tags             = var.tags
      }
    }
  } if local.private_dns_zones_enabled[key] && try(value.private_dns_zones.auto_registration_zone_enabled, false) }
  private_dns_zones_virtual_network_links = {
    for key, value in module.hub_and_spoke_vnet.virtual_networks : key => {
      vnet_resource_id                            = value.id
      virtual_network_link_name_template_override = try(var.hub_virtual_networks[key].private_dns_zones.dns_zones.private_dns_zone_network_link_name_template, null)
    }
  }
}
