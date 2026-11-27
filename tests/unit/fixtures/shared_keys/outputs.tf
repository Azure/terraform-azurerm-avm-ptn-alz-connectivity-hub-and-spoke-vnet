output "configuration" {
  description = "Synthetic old-input configuration used by the regression."
  sensitive   = true
  value       = local.input_hub_virtual_networks
}

output "public" {
  description = "Plan-known public names and instance keys for cross-run compatibility assertions."
  value = {
    virtual_networks = { for hub_key, name in nonsensitive(module.sut.virtual_network_resource_names) : hub_key => nonsensitive(name) }
    gateways         = nonsensitive(keys(module.sut.virtual_network_gateway_resource_ids))
    er_connections = nonsensitive({
      for gateway_key, connections in module.sut.virtual_network_gateway_express_route_circuit_connection_resource_ids : gateway_key => nonsensitive(keys(connections))
    })
    local_connections = nonsensitive({
      for gateway_key, connections in module.sut.virtual_network_gateway_local_network_gateway_connection_resource_ids : gateway_key => nonsensitive(keys(connections))
    })
    local_gateways = nonsensitive({
      for gateway_key, gateways in module.sut.virtual_network_gateway_local_network_gateway_resource_ids : gateway_key => nonsensitive(keys(gateways))
    })
  }
}

output "services" {
  description = "Plan-known service instance keys, including the private DNS zone keys of each hub."
  value = {
    bastions     = nonsensitive(keys(module.sut.bastion_host_resource_ids))
    dns_zones    = nonsensitive({ for hub_key, zones in module.sut.private_link_private_dns_zones_maps : hub_key => nonsensitive(keys(zones)) })
    firewalls    = nonsensitive(keys(module.sut.firewall_resource_ids))
    nat_gateways = nonsensitive(keys(module.sut.nat_gateways))
    resolvers    = nonsensitive(keys(module.sut.dns_resolver_resource_ids))
    route_tables = nonsensitive(keys(module.sut.route_tables_gateway_resource_ids))
  }
}

output "shared_key_sensitivity" {
  description = "Sensitivity of each original input leaf before any test output marks are applied."
  sensitive   = true
  value = {
    for hub_key, hub in local.input_hub_virtual_networks : hub_key => {
      er_connection  = issensitive(hub.virtual_network_gateways.express_route.express_route_circuits["primary/one"].connection.shared_key)
      er_peering     = issensitive(hub.virtual_network_gateways.express_route.express_route_circuits["primary/one"].peering.shared_key)
      er_local       = issensitive(hub.virtual_network_gateways.express_route.local_network_gateways["existing:one"].connection.shared_key)
      vpn_connection = issensitive(hub.virtual_network_gateways.vpn.local_network_gateways["office:one"].connection.shared_key)
    }
  }
}

output "shared_keys" {
  description = "Synthetic values at all four original paths after input selection and templating."
  sensitive   = true
  value = {
    for hub_key, hub in local.input_hub_virtual_networks : hub_key => {
      er_connection  = hub.virtual_network_gateways.express_route.express_route_circuits["primary/one"].connection.shared_key
      er_peering     = hub.virtual_network_gateways.express_route.express_route_circuits["primary/one"].peering.shared_key
      er_local       = hub.virtual_network_gateways.express_route.local_network_gateways["existing:one"].connection.shared_key
      vpn_connection = hub.virtual_network_gateways.vpn.local_network_gateways["office:one"].connection.shared_key
    }
  }
}

output "template_equivalent" {
  description = "Golden comparison against the unchanged whole-input template."
  value       = module.template.equivalent
}
