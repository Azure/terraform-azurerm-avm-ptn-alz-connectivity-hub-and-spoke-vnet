resource "terraform_data" "shared_key" {
  for_each = toset(["er_connection", "er_peering", "er_local", "vpn_connection"])

  input = "synthetic-${each.key}"
}

locals {
  hub_keys = ["primary-hub", "secondary-hub"]
  hub_virtual_networks = {
    for hub_key in local.hub_keys : hub_key => {
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
        virtual_network_gateway_vpn           = true
      }
      nat_gateway = {
        ip_configurations = { primary = {} }
      }
      private_dns_zones = {
        private_link_private_dns_zones = {}
        private_link_private_dns_zones_regex_filter = {
          enabled = false
        }
        private_link_private_dns_zones_additional = {
          fixture = { zone_name = "${hub_key}.internal", private_dns_zone_supports_private_link = false }
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
            "primary/one" = {
              id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-shared-key-test/providers/Microsoft.Network/expressRouteCircuits/${hub_key}"
              connection = {
                shared_key = sensitive(terraform_data.shared_key["er_connection"].output)
              }
              peering = {
                peering_type                  = "AzurePrivatePeering"
                vlan_id                       = 1002
                peer_asn                      = 65010
                primary_peer_address_prefix   = "169.254.21.0/30"
                secondary_peer_address_prefix = "169.254.22.0/30"
                shared_key                    = sensitive(terraform_data.shared_key["er_peering"].output)
              }
            }
          }
          local_network_gateways = {
            "er:office" = {
              id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-shared-key-test/providers/Microsoft.Network/localNetworkGateways/er-office"
              connection = { type = "IPsec", shared_key = sensitive(terraform_data.shared_key["er_local"].output) }
            }
          }
        }
        vpn = {
          local_network_gateways = {
            "vpn:office" = {
              id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-shared-key-test/providers/Microsoft.Network/localNetworkGateways/vpn-office"
              connection = { type = "IPsec", shared_key = sensitive(terraform_data.shared_key["vpn_connection"].output) }
            }
          }
        }
      }
    }
  }
}

module "direct" {
  source = "../../../../"

  enable_telemetry     = false
  hub_virtual_networks = local.hub_virtual_networks
  tags                 = {}
}

module "template" {
  source = "../shared_keys/template"

  hub_virtual_networks = local.hub_virtual_networks
}

# The example's adapter and module call; the example itself cannot be a child here because mocks do not replace its own azurerm provider block.
module "adapted" {
  source = "../../../../"

  enable_telemetry     = false
  hub_virtual_networks = nonsensitive(module.template.configuration)
  tags                 = {}
}