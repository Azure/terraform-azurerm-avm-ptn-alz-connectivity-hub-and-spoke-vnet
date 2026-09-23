mock_provider "azurerm" {}
mock_provider "azapi" {
  mock_data "azapi_resource_action" {
    defaults = {
      output = {
        value = [{
          name        = "westeurope"
          displayName = "West Europe"
          metadata = {
            geography      = "Europe"
            regionCategory = "Recommended"
            regionType     = "Physical"
            pairedRegion   = [{ name = "northeurope" }]
          }
          availabilityZoneMappings = [{ logicalZone = "1" }, { logicalZone = "2" }, { logicalZone = "3" }]
        }]
      }
    }
  }
}
mock_provider "random" {}
mock_provider "modtm" {}

variables {
  enable_telemetry = false
  tags             = {}
  hub_virtual_networks = {
    primary-hub = {
      location          = "westeurope"
      default_parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-shared-key-test"
      enabled_resources = {
        firewall                              = false
        firewall_policy                       = false
        private_dns_zones                     = false
        private_dns_resolver                  = false
        dns_resolver_policy                   = false
        bastion                               = true
        virtual_network_gateway_express_route = true
        virtual_network_gateway_vpn           = false
      }
      virtual_network_gateways = {
        route_table_creation_enabled               = true
        route_table_gateway_firewall_route_enabled = false
        express_route = {
          express_route_circuits = {
            primary = {
              id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-shared-key-test/providers/Microsoft.Network/expressRouteCircuits/primary"
              connection = {}
              peering = {
                peering_type                  = "AzurePrivatePeering"
                vlan_id                       = 1002
                peer_asn                      = 65010
                primary_peer_address_prefix   = "169.254.21.0/30"
                secondary_peer_address_prefix = "169.254.22.0/30"
              }
            }
          }
        }
      }
    }
  }
}

run "control" {
  command = plan
}

run "services" {
  command = plan

  variables {
    tags = null
    hub_virtual_networks = {
      for hub_key, hub in var.hub_virtual_networks : hub_key => merge(hub, {
        enabled_resources = merge(hub.enabled_resources, {
          firewall             = true
          firewall_policy      = true
          private_dns_zones    = true
          private_dns_resolver = true
          dns_resolver_policy  = true
        })
        private_dns_zones = {
          private_link_private_dns_zones = {}
          private_link_private_dns_zones_additional = {
            fixture = { zone_name = "fixture.internal", private_dns_zone_supports_private_link = false }
          }
        }
        dns_resolver_policy = {
          domain_lists = { fixture = { domains = ["example.invalid"] } }
          rules        = { fixture = { priority = 100, domain_list_keys = ["fixture"] } }
        }
      })
    }
  }

  assert {
    condition = (
      keys(output.firewall_resource_ids) == ["primary-hub"] &&
      keys(output.firewall_policies) == ["primary-hub"] &&
      keys(output.dns_resolver_resource_ids) == ["primary-hub"] &&
      keys(output.dns_resolver_inbound_endpoint_ip_addresses["primary-hub"]) == ["dns"] &&
      keys(output.dns_resolver_policy_domain_list_resource_ids) == ["primary-hub/fixture"] &&
      keys(output.dns_resolver_policy_security_rule_resource_ids) == ["primary-hub/fixture"]
    )
    error_message = "The service control must create the firewall, resolver and DNS policy graph."
  }
}

run "sensitive_leaves" {
  command = plan

  variables {
    hub_virtual_networks = {
      for hub_key, hub in var.hub_virtual_networks : hub_key => merge(hub, {
        virtual_network_gateways = merge(hub.virtual_network_gateways, {
          express_route = merge(hub.virtual_network_gateways.express_route, {
            express_route_circuits = {
              for circuit_key, circuit in hub.virtual_network_gateways.express_route.express_route_circuits : circuit_key => merge(circuit, {
                connection = merge(circuit.connection, { shared_key = sensitive("legacy-leaf-connection") })
                peering    = merge(circuit.peering, { shared_key = sensitive("legacy-leaf-peering") })
              })
            }
          })
        })
      })
    }
  }

  assert {
    condition     = !issensitive(keys(module.virtual_network_gateway)) && keys(module.virtual_network_gateway) == ["primary-hub-express-route"]
    error_message = "Known public gateway identities must not depend on shared-key sensitivity."
  }
}

run "sensitive_services" {
  command = plan

  variables {
    tags = null
    hub_virtual_networks = {
      for hub_key, hub in var.hub_virtual_networks : hub_key => merge(hub, {
        enabled_resources = merge(hub.enabled_resources, {
          firewall             = true
          firewall_policy      = true
          private_dns_zones    = true
          private_dns_resolver = true
          dns_resolver_policy  = true
        })
        private_dns_zones = {
          private_link_private_dns_zones = {}
          private_link_private_dns_zones_additional = {
            fixture = { zone_name = "fixture.internal", private_dns_zone_supports_private_link = false }
          }
        }
        dns_resolver_policy = {
          domain_lists = { fixture = { domains = [sensitive("example.invalid")] } }
          rules        = { fixture = { priority = 100, domain_list_keys = ["fixture"] } }
        }
        virtual_network_gateways = merge(hub.virtual_network_gateways, {
          express_route = merge(hub.virtual_network_gateways.express_route, {
            express_route_circuits = {
              for circuit_key, circuit in hub.virtual_network_gateways.express_route.express_route_circuits : circuit_key => merge(circuit, {
                connection = merge(circuit.connection, { shared_key = sensitive("legacy-leaf-connection") })
                peering    = merge(circuit.peering, { shared_key = sensitive("legacy-leaf-peering") })
              })
            }
          })
        })
      })
    }
  }

  assert {
    condition = (
      keys(output.firewall_resource_ids) == ["primary-hub"] &&
      keys(output.firewall_policies) == ["primary-hub"] &&
      keys(output.dns_resolver_resource_ids) == ["primary-hub"] &&
      keys(output.dns_resolver_inbound_endpoint_ip_addresses["primary-hub"]) == ["dns"] &&
      keys(output.dns_resolver_policy_domain_list_resource_ids) == ["primary-hub/fixture"] &&
      keys(output.dns_resolver_policy_security_rule_resource_ids) == ["primary-hub/fixture"]
    )
    error_message = "Sensitive inputs must preserve the complete enabled service graph."
  }

  assert {
    condition     = issensitive(local.dns_resolver_policy["primary-hub"].domain_lists["fixture"].domains[0])
    error_message = "Publishing structural keys must not declassify business payload values."
  }
}