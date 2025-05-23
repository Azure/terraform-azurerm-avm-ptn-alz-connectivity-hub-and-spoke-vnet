locals {
  hub_virtual_networks = {
    for key, value in var.hub_virtual_networks : key => merge(value.hub_virtual_network, {
      ddos_protection_plan_id = (local.ddos_protection_plan_enabled ?
        module.ddos_protection_plan[0].resource_id :
      merge({ ddos = module.ddos_protection_plan }, { ddos_id = try(value.hub_virtual_network.ddos_protection_plan_id, null) }).ddos_id) # This is building an implicit dependency on the DDOS protection plan for the use case of it being destroyed after initialy being created
      resource_group_creation_enabled = try(value.hub_virtual_network.resource_group_creation_enabled, false)
      resource_group_lock_enabled     = try(value.hub_virtual_network.resource_group_lock_enabled, false)
      mesh_peering_enabled            = try(value.hub_virtual_network.mesh_peering_enabled, true)
      firewall                        = local.firewalls[key]
      subnets                         = merge(local.subnets[key], value.hub_virtual_network.subnets)
    })
  }
}
