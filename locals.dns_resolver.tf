locals {
  private_dns_resolver_enabled = { for key, value in var.hub_virtual_networks : key => try(value.private_dns_resolver.enabled, try(value.private_dns_resolver, null) != null) }
}

locals {
  private_dns_resolver_ip_addresses = { for key, value in var.hub_virtual_networks : key =>
    (try(value.private_dns_resolver.dns_resolver.ip_address, null) == null ?
      cidrhost(value.private_dns_resolver.subnet_address_prefix, 4) :
    value.private_dns_resolver.dns_resolver.ip_address) if local.private_dns_resolver_enabled[key]
  }
  private_dns_resolver = { for key, value in var.hub_virtual_networks : key => merge({
    location = value.hub_virtual_network.location
    resource_group_name = value.hub_virtual_network.resource_group_name
    inbound_endpoints = local.private_dns_zones_enabled[key] ? {
      dns = {
        name        = "dns"
        subnet_name                  = module.hub_and_spoke_vnet.virtual_networks[key].subnets["${key}-dns_resolver"].name
        private_ip_allocation_method = "Static"
        private_ip_address           = local.private_dns_resolver_ip_addresses[key]
      }
    } : {}
  }, value.private_dns_resolver.dns_resolver) if local.private_dns_resolver_enabled[key] }
}
