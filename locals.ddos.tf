locals {
  ddos_protection_plan         = local.ddos_protection_plan_enabled ? var.hub_and_spoke_networks_settings.ddos_protection_plan : null
  ddos_protection_plan_enabled = try(var.hub_and_spoke_networks_settings.ddos_protection_plan.enabled, try(var.hub_and_spoke_networks_settings.ddos_protection_plan, null) != null)
}
