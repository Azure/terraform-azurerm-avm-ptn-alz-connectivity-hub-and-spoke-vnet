locals {
  ddos_protection_plan_enabled             = var.hub_and_spoke_networks_settings.enabled_resources.ddos_protection_plan
  ddos_protection_plan_location            = coalesce(var.hub_and_spoke_networks_settings.ddos_protection_plan.location, local.primary_location)
  ddos_protection_plan_name                = coalesce(var.hub_and_spoke_networks_settings.ddos_protection_plan.name, "ddos-hub-${local.primary_location}")
  ddos_protection_plan_resource_group_name = coalesce(var.hub_and_spoke_networks_settings.ddos_protection_plan.resource_group_name, local.hub_virtual_networks_resource_group_names[local.primary_region_key])
  ddos_protection_plan_tags                = coalesce(var.hub_and_spoke_networks_settings.ddos_protection_plan.tags, var.tags, {})
}
