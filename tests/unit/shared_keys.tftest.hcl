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

run "sensitive_leaves" {
  command = plan

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
          private_dns_zones                     = true
          private_dns_resolver                  = false
          dns_resolver_policy                   = false
          bastion                               = true
          nat_gateway                           = true
          virtual_network_gateway_express_route = true
          virtual_network_gateway_vpn           = false
        }
        nat_gateway = {
          ip_configurations = { primary = {} }
        }
        private_dns_zones = {
          private_link_private_dns_zones = {}
          private_link_private_dns_zones_additional = {
            fixture = { zone_name = "fixture.internal", private_dns_zone_supports_private_link = false }
          }
          virtual_network_link_default_virtual_networks = {
            custom = {
              virtual_network_resource_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-shared-key-test/providers/Microsoft.Network/virtualNetworks/other"
              virtual_network_link_name_template_override = "custom-link"
            }
          }
        }
        virtual_network_gateways = {
          route_table_creation_enabled               = true
          route_table_gateway_firewall_route_enabled = false
          express_route = {
            express_route_circuits = {
              primary = {
                id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-shared-key-test/providers/Microsoft.Network/expressRouteCircuits/primary"
                connection = { shared_key = sensitive("legacy-leaf-connection") }
                peering = {
                  peering_type                  = "AzurePrivatePeering"
                  vlan_id                       = 1002
                  peer_asn                      = 65010
                  primary_peer_address_prefix   = "169.254.21.0/30"
                  secondary_peer_address_prefix = "169.254.22.0/30"
                  shared_key                    = sensitive("legacy-leaf-peering")
                }
              }
            }
          }
        }
      }
    }
  }

  assert {
    condition     = !issensitive(keys(module.virtual_network_gateway)) && toset(keys(module.virtual_network_gateway)) == toset(["primary-hub-express-route"])
    error_message = "Known public gateway identities must not depend on shared_key sensitivity."
  }

  assert {
    condition = (
      keys(module.gateway_route_table) == ["primary-hub"] &&
      keys(module.bastion_public_ip) == ["primary-hub"] &&
      local.virtual_network_default_ip_prefixes["primary-hub"] == "10.0.0.0/22"
    )
    error_message = "Sensitive keys must not change route/Bastion membership or default IP allocation."
  }

  assert {
    condition = (
      keys(output.nat_gateways["primary-hub"].public_ip_addresses) == ["primary"] &&
      output.private_link_private_dns_zones_maps["primary-hub"]["fixture"].virtual_network_links["custom"].name == "custom-link"
    )
    error_message = "Sensitive shared keys must not taint NAT IP or DNS link instance identities."
  }
}