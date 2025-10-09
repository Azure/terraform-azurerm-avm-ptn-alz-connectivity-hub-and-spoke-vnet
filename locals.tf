locals {
  has_regions = length(var.hub_virtual_networks) > 1
  hub_virtual_networks = {
    for key, value in var.hub_virtual_networks : key => merge(value.hub_virtual_network, {
      parent_id = coalesce(value.hub_virtual_network.parent_id, value.default_parent_id)
      name      = coalesce(value.hub_virtual_network.name, local.default_names[key].virtual_network_name)
      location  = value.location
      ddos_protection_plan_id = (local.ddos_protection_plan_enabled ?
        module.ddos_protection_plan[0].resource_id :
      merge({ ddos = module.ddos_protection_plan }, { ddos_id = value.hub_virtual_network.ddos_protection_plan_id }).ddos_id) # This is building an implicit dependency on the DDOS protection plan for the use case of it being destroyed after initially being created
      firewall                      = local.firewalls[key]
      subnets                       = merge(local.subnets[key], value.hub_virtual_network.subnets)
      address_space                 = coalesce(value.hub_virtual_network.address_space, [local.virtual_network_default_ip_prefixes[key]])
      routing_address_space         = coalesce(value.hub_virtual_network.routing_address_space, [value.default_hub_address_space])
      route_table_name_firewall     = coalesce(value.hub_virtual_network.route_table_name_firewall, local.default_names[key].route_table_firewall_name)
      route_table_name_user_subnets = coalesce(value.hub_virtual_network.route_table_name_user_subnets, local.default_names[key].route_table_user_subnets_name)
    })
  }
  hub_virtual_networks_resource_group_names = { for key, value in var.hub_virtual_networks : key => provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", coalesce(value.default_parent_id, value.hub_virtual_network.parent_id)).resource_group_name }
  primary_location                          = local.has_regions ? var.hub_virtual_networks[local.primary_region_key].location : null
  primary_region_key                        = local.has_regions ? keys(var.hub_virtual_networks)[0] : null
}
