locals {
  private_dns_zones_enabled = { for key, value in var.hub_virtual_networks : key => value.enabled_resources.private_dns_zones }
}

locals {
  private_dns_zones = { for key, value in var.hub_virtual_networks : key => {
    location            = value.location
    resource_group_name = coalesce(value.private_dns_zones.resource_group_name, local.hub_virtual_networks_resource_group_names[key])
    private_link_private_dns_zones_regex_filter = value.private_dns_zones.private_link_private_dns_zones_regex_filter != null ? value.private_dns_zones.private_link_private_dns_zones_regex_filter : {
      enabled = key != local.primary_region_key
    }
    # private_dns_settings = value.private_dns_zones
    private_link_excluded_zones = value.private_dns_zones.private_link_excluded_zones
    private_link_private_dns_zones_additional = value.private_dns_zones.private_link_private_dns_zones_additional
    private_link_private_dns_zones = {
      for private_link_dns_zone_k, private_link_dns_zone_v in value.private_dns_zones.private_link_private_dns_zones : private_link_dns_zone_k => {
        zone_name          = private_link_dns_zone_v.zone_name
        private_dns_zone_supports_private_link = coalesce(private_link_dns_zone_v.private_dns_zone_supports_private_link, true)
        virtual_network_links = {
          for vnet_key, vnet_value in module.hub_and_spoke_vnet.virtual_networks : vnet_key => {
            virtual_network_resource_id = vnet_value.id
            resolution_policy = coalesce(var.hub_virtual_networks[vnet_key].private_dns_zones.private_link_private_dns_zones[private_link_dns_zone_k].resolution_policy, private_link_dns_zone_v.resolution_policy, "Default")
          } #if contains(module.hub_and_spoke_vnet.virtual_networks[vnet_key].private_dns_zones.private_link_private_dns_zones, private_link_dns_zone_k)

        }
      }
    }
    tags                 = coalesce(value.private_dns_zones.tags, var.tags, {})
  } if local.private_dns_zones_enabled[key] }
  private_dns_zones_auto_registration = { for key, value in var.hub_virtual_networks : key => {
    location            = value.location
    domain_name         = coalesce(value.private_dns_zones.auto_registration_zone_name, "${value.location}.azure.local")
    resource_group_name = coalesce(value.private_dns_zones.auto_registration_zone_resource_group_name, local.private_dns_zones[key].resource_group_name)
    virtual_network_links = {
      auto_registration = {
        vnetlinkname     = "vnet-link-${key}-auto-registration"
        vnetid           = module.hub_and_spoke_vnet.virtual_networks[key].id
        autoregistration = true
        tags             = var.tags
      }
    }
  } if local.private_dns_zones_enabled[key] && value.private_dns_zones.auto_registration_zone_enabled }
  # private_dns_zones_virtual_network_links = {
  #   for key, value in module.hub_and_spoke_vnet.virtual_networks : key => {
  #     virtual_network_resource_id                            = value.id
  #     virtual_network_link_name_template_override = var.hub_virtual_networks[key].private_dns_zones.private_dns_zone_network_link_name_template
  #   }
  # }
}
