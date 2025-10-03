locals {
  private_dns_resolver_enabled = { for key, value in var.hub_virtual_networks : key => value.private_dns_resolver.enabled }
}

locals {
  private_dns_resolver = { for key, value in var.hub_virtual_networks : key => {
    name                = value.private_dns_resolver.name
    location            = value.hub_virtual_network.location
    resource_group_name = local.hub_virtual_networks_resource_group_names[key]
    inbound_endpoints = local.private_dns_zones_enabled[key] && value.private_dns_resolver.default_inbound_endpoint_enabled ? merge({
      dns = {
        name                         = "dns"
        subnet_name                  = module.hub_and_spoke_vnet.virtual_networks[key].subnets["${key}-dns_resolver"].name
        private_ip_allocation_method = "Static"
        private_ip_address           = local.private_dns_resolver_ip_addresses[key]
      }
    }, value.private_dns_resolver.inbound_endpoints) : value.private_dns_resolver.inbound_endpoints
    outbound_endpoints = value.private_dns_resolver.outbound_endpoints
    tags               = coalesce(value.private_dns_resolver.tags, var.tags, {})
    } if local.private_dns_resolver_enabled[key]
  }
  private_dns_resolver_ip_addresses = { for key, value in var.hub_virtual_networks : key =>
    (value.private_dns_resolver.ip_address == null ?
      cidrhost(value.private_dns_resolver.subnet_address_prefix, 4) :
    value.private_dns_resolver.ip_address) if local.private_dns_resolver_enabled[key]
  }
}
