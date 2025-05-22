locals {
  bastion_subnets = { for key, value in var.hub_virtual_networks : key => {
    bastion = {
      hub_network_key  = key
      address_prefixes = [value.bastion.subnet_address_prefix]
      name             = "AzureBastionSubnet"
      route_table = {
        assign_generated_route_table = false
      }
      default_outbound_access_enabled = try(value.bastion.subnet_default_outbound_access_enabled, false)
    } } if local.bastions_enabled[key]
  }
  gateway_subnets = { for key, value in var.hub_virtual_networks : key => {
    gateway = {
      hub_network_key  = key
      address_prefixes = [value.virtual_network_gateways.subnet_address_prefix]
      name             = "GatewaySubnet"
      route_table = {
        assign_generated_route_table = false
      }
      default_outbound_access_enabled = try(value.virtual_network_gateways.subnet_default_outbound_access_enabled, false)
    } } if try(value.virtual_network_gateways.subnet_address_prefix, null) != null && (local.virtual_network_gateways_express_route_enabled[key] || local.virtual_network_gateways_vpn_enabled[key])
  }
  private_dns_resolver_subnets = { for key, value in var.hub_virtual_networks : key => {
    dns_resolver = {
      hub_network_key  = key
      address_prefixes = [value.private_dns_zones.subnet_address_prefix]
      name             = value.private_dns_zones.subnet_name
      route_table = {
        assign_generated_route_table = false
      }
      delegations = [{
        name = "Microsoft.Network.dnsResolvers"
        service_delegation = {
          name = "Microsoft.Network/dnsResolvers"
        }
      }]
      default_outbound_access_enabled = try(value.private_dns_zones.subnet_default_outbound_access_enabled, false)
    } } if local.private_dns_zones_enabled[key]
  }
  subnets = { for key, value in var.hub_virtual_networks : key => merge(lookup(local.private_dns_resolver_subnets, key, {}), lookup(local.bastion_subnets, key, {}), lookup(local.gateway_subnets, key, {})) }
}
