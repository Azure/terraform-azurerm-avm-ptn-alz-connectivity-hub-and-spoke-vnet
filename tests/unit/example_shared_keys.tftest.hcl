mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      subscription_id = "00000000-0000-0000-0000-000000000000"
      tenant_id       = "00000000-0000-0000-0000-000000000000"
      client_id       = "00000000-0000-0000-0000-000000000000"
      object_id       = "00000000-0000-0000-0000-000000000000"
    }
  }
}
mock_provider "azapi" {
  source = "./tests/unit/mocks"
}
mock_provider "random" {}
mock_provider "modtm" {}

run "example" {
  command = plan

  module {
    source = "./examples/full-multi-region"
  }

  variables {
    enable_telemetry = false
    custom_replacements = {
      names = { hub = "primary-hub", site = "branch" }
    }
    hub_virtual_networks = {
      "$${hub}" = {
        location          = "westeurope"
        default_parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-shared-key-test"
        enabled_resources = {
          firewall                              = false
          firewall_policy                       = false
          private_dns_zones                     = false
          private_dns_resolver                  = false
          dns_resolver_policy                   = false
          bastion                               = false
          virtual_network_gateway_express_route = true
          virtual_network_gateway_vpn           = true
        }
        virtual_network_gateways = {
          express_route = {
            express_route_circuits = {
              "primary-$${site}" = {
                id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-shared-key-test/providers/Microsoft.Network/expressRouteCircuits/primary"
                connection = { shared_key = sensitive("erc-$${site}") }
                peering = {
                  peering_type                  = "AzurePrivatePeering"
                  vlan_id                       = 1002
                  peer_asn                      = 65010
                  primary_peer_address_prefix   = "169.254.21.0/30"
                  secondary_peer_address_prefix = "169.254.22.0/30"
                  shared_key                    = sensitive("true")
                }
              }
            }
            local_network_gateways = {
              "er-$${site}" = {
                id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-shared-key-test/providers/Microsoft.Network/localNetworkGateways/er-branch"
                connection = { type = "IPsec", shared_key = sensitive("er-local-$${site}") }
              }
            }
          }
          vpn = {
            local_network_gateways = {
              "office-$${site}" = {
                id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-shared-key-test/providers/Microsoft.Network/localNetworkGateways/branch"
                connection = { type = "IPsec", shared_key = sensitive("vpn-$${site}") }
              }
            }
          }
        }
      }
    }
  }

  assert {
    condition     = !issensitive(jsonencode(local.config_templating_inputs)) && issensitive(output.config_outputs)
    error_message = "The template copy must omit secrets and the complete configuration output must be sensitive."
  }

  assert {
    condition = (
      keys(output.config_outputs) == ["custom_replacements", "outputs"] &&
      output.config_outputs.outputs.hub_virtual_networks["primary-hub"].virtual_network_gateways.express_route.express_route_circuits["primary-branch"].connection.shared_key == "erc-branch" &&
      output.config_outputs.outputs.hub_virtual_networks["primary-hub"].virtual_network_gateways.express_route.express_route_circuits["primary-branch"].peering.shared_key == "true" &&
      output.config_outputs.outputs.hub_virtual_networks["primary-hub"].virtual_network_gateways.express_route.local_network_gateways["er-branch"].connection.shared_key == "er-local-branch" &&
      output.config_outputs.outputs.hub_virtual_networks["primary-hub"].virtual_network_gateways.vpn.local_network_gateways["office-branch"].connection.shared_key == "vpn-branch"
    )
    error_message = "The complete output must preserve original template semantics at all four transformed paths, without internal markers."
  }

  assert {
    condition     = keys(module.test.virtual_network_gateway_resource_ids) == ["primary-hub-express-route", "primary-hub-vpn"]
    error_message = "The actual example must plan both gateways using only the original input."
  }
}