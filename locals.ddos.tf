locals {
  ddos_protection_plan = local.ddos_protection_plan_enabled ? {
    location            = coalesce(var.hub_and_spoke_networks_settings.ddos_protection_plan.location, local.primary_location)
    name                = coalesce(var.hub_and_spoke_networks_settings.ddos_protection_plan.name, local.default_names[local.primary_region_key].ddos_protection_plan_name)
    resource_group_name = coalesce(var.hub_and_spoke_networks_settings.ddos_protection_plan.resource_group_name, local.hub_virtual_networks_resource_group_names[local.primary_region_key])
    tags                = coalesce(var.hub_and_spoke_networks_settings.ddos_protection_plan.tags, var.tags, {})
  } : null
  ddos_protection_plan_enabled = var.hub_and_spoke_networks_settings.enabled_resources.ddos_protection_plan && local.has_regions
  ddos_protection_plan_id      = local.ddos_protection_plan_enabled ? module.ddos_protection_plan[0].resource_id : null
}
