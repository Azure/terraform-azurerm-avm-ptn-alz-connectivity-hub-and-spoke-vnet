locals {
  bastions_enabled = { for key, value in var.hub_virtual_networks : key => value.bastion.enabled }
}

locals {
  bastion_host_public_ips = {
    for key, value in var.hub_virtual_networks : key => {
      location            = value.hub_virtual_network.location
      resource_group_name = local.hub_virtual_networks_resource_group_names[key]
      tags                = coalesce(value.bastion.bastion_public_ip.tags, var.tags, {})
      public_ip_settings  = value.bastion.bastion_public_ip
    } if local.bastions_enabled[key]
  }
  bastion_hosts = {
    for key, value in var.hub_virtual_networks : key => {
      location            = value.hub_virtual_network.location
      resource_group_name = local.hub_virtual_networks_resource_group_names[key]
      zones               = coalesce(value.bastion.zones, local.bastion_host_public_ips[key].public_ip_settings.zones)
      tags                = coalesce(value.bastion.tags, var.tags, {})
      ip_configuration = {
        name                 = "bastion-ip-config"
        subnet_id            = module.hub_and_spoke_vnet.virtual_networks[key].subnet_ids["${key}-bastion"]
        public_ip_address_id = module.bastion_public_ip[key].public_ip_id
        create_public_ip     = false
      }
      bastion_settings = value.bastion
    } if local.bastions_enabled[key]
  }
}
