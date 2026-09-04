locals {
  bastions_enabled = { for key, value in var.hub_virtual_networks : key => value.enabled_resources.bastion }
}

locals {
  bastion_host_public_ips = {
    for key, value in var.hub_virtual_networks : key => {
      name                = coalesce(value.bastion.bastion_public_ip.name, local.default_names[key].bastion_host_public_ip_name)
      location            = value.location
      resource_group_name = coalesce(value.bastion.bastion_public_ip.resource_group_name, value.bastion.resource_group_name, local.hub_virtual_networks_resource_group_names[key])
      tags                = coalesce(value.bastion.bastion_public_ip.tags, var.tags, {})
      zones               = coalesce(value.bastion.bastion_public_ip.zones, local.availability_zones[key])
      public_ip_settings  = value.bastion.bastion_public_ip
    } if local.bastions_enabled[key] && !value.bastion.private_only_enabled
  }
  bastion_hosts = {
    for key, value in var.hub_virtual_networks : key => {
      name      = coalesce(value.bastion.name, local.default_names[key].bastion_host_name)
      location  = value.location
      parent_id = coalesce(value.bastion.parent_id, value.default_parent_id, value.hub_virtual_network.parent_id)
      zones     = value.bastion.private_only_enabled ? coalesce(value.bastion.zones, local.availability_zones[key], []) : coalesce(value.bastion.zones, local.bastion_host_public_ips[key].zones, local.availability_zones[key], [])
      tags      = coalesce(value.bastion.tags, var.tags, {})
      ip_configuration = value.bastion.private_only_enabled ? {
        name                 = "bastion-ip-config"
        subnet_id            = module.hub_and_spoke_vnet.virtual_networks[key].subnet_ids["${key}-bastion"]
        public_ip_address_id = null
        create_public_ip     = false
        } : {
        name                 = "bastion-ip-config"
        subnet_id            = module.hub_and_spoke_vnet.virtual_networks[key].subnet_ids["${key}-bastion"]
        public_ip_address_id = module.bastion_public_ip[key].public_ip_id
        create_public_ip     = false
      }
      bastion_settings = value.bastion
    } if local.bastions_enabled[key]
  }
}
