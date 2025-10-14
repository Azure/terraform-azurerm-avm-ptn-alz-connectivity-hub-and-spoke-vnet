locals {
  bastion_subnets = { for key, value in var.hub_virtual_networks : key => {
    bastion = {
      hub_network_key  = key
      address_prefixes = [coalesce(value.bastion.subnet_address_prefix, local.virtual_network_subnet_default_ip_prefixes[key]["bastion"])]
      name             = "AzureBastionSubnet"
      route_table = {
        id                           = null
        assign_generated_route_table = false
      }
      default_outbound_access_enabled = value.bastion.subnet_default_outbound_access_enabled
    } } if local.bastions_enabled[key]
  }
  gateway_subnets = { for key, value in var.hub_virtual_networks : key => {
    gateway = {
      hub_network_key  = key
      address_prefixes = [coalesce(value.virtual_network_gateways.subnet_address_prefix, local.virtual_network_subnet_default_ip_prefixes[key]["gateway"])]
      name             = "GatewaySubnet"
      route_table = {
        id                           = local.gateway_route_table_enabled[key] ? module.gateway_route_table[key].resource_id : null
        assign_generated_route_table = false
      }
      default_outbound_access_enabled = value.virtual_network_gateways.subnet_default_outbound_access_enabled
    } } if(local.virtual_network_gateways_express_route_enabled[key] || local.virtual_network_gateways_vpn_enabled[key])
  }
  private_dns_resolver_subnets = { for key, value in var.hub_virtual_networks : key => {
    dns_resolver = {
      hub_network_key  = key
      address_prefixes = [coalesce(value.private_dns_resolver.subnet_address_prefix, local.virtual_network_subnet_default_ip_prefixes[key]["dns_resolver"])]
      name             = value.private_dns_resolver.subnet_name
      route_table = {
        id                           = null
        assign_generated_route_table = false
      }
      delegations = [{
        name = "Microsoft.Network.dnsResolvers"
        service_delegation = {
          name = "Microsoft.Network/dnsResolvers"
        }
      }]
      default_outbound_access_enabled = value.private_dns_resolver.subnet_default_outbound_access_enabled
    } } if local.private_dns_resolver_enabled[key]
  }
  subnets = { for key, value in var.hub_virtual_networks : key => merge(lookup(local.private_dns_resolver_subnets, key, {}), lookup(local.bastion_subnets, key, {}), lookup(local.gateway_subnets, key, {})) }
}
