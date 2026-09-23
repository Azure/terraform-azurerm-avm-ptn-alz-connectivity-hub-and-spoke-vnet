locals {
  input_hub_virtual_networks = {
    direct = local.hub_virtual_networks
    # Removes only the container mark of the child output; the adapter's per-secret marks remain, as in the example.
    template = nonsensitive(module.template.configuration)
    # Unchanged whole-configuration templating: every value inherits the secrets' marks.
    whole = module.template.original
  }[var.input_mode]
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-shared-keys"
  keys = {
    for key_kind in ["er_connection", "er_peering", "er_local", "vpn_connection"] : key_kind => sensitive(var.unknown_keys ? tostring(terraform_data.key[key_kind].output) : var.shared_keys[key_kind])
  }
  private_dns_zones_additional = {
    for zone_key, zone in {
      fixture = {
        zone_name                              = "fixture.internal"
        private_dns_zone_supports_private_link = false
      }
      iterated = {
        zone_name = "privatelink.{partitionId}.fixture.internal"
        custom_iterator = {
          replacement_placeholder = "partitionId"
          replacement_values      = { one = "1", two = "2" }
        }
      }
    } : zone_key => zone if zone_key == "fixture" || var.user_iterator_zone
  }
  hub_virtual_networks = {
    for hub_key in ["alpha-hub", "beta-hub"] : hub_key => {
      location          = "westeurope"
      default_parent_id = local.parent_id
      enabled_resources = {
        firewall                              = var.services
        firewall_policy                       = var.services
        private_dns_zones                     = var.services
        private_dns_resolver                  = var.services
        dns_resolver_policy                   = var.services
        bastion                               = var.services
        nat_gateway                           = var.services
        virtual_network_gateway_express_route = var.gateways_enabled
        virtual_network_gateway_vpn           = var.gateways_enabled
      }
      nat_gateway = {
        ip_configurations = { primary = {} }
      }
      private_dns_zones = {
        private_link_private_dns_zones              = {}
        private_link_private_dns_zones_regex_filter = { enabled = false }
        private_link_private_dns_zones_additional   = local.private_dns_zones_additional
        virtual_network_link_default_virtual_networks = {
          custom = {
            virtual_network_resource_id                 = "${local.parent_id}/providers/Microsoft.Network/virtualNetworks/other"
            virtual_network_link_name_template_override = "custom-link"
          }
        }
      }
      dns_resolver_policy = {
        domain_lists = { fixture = { domains = ["example.invalid"] } }
        rules        = { fixture = { priority = 100, domain_list_keys = ["fixture"] } }
      }
      virtual_network_gateways = {
        subnet_address_prefix                      = var.services ? { "alpha-hub" = "10.0.3.224/27", "beta-hub" = "10.1.3.224/27" }[hub_key] : null
        route_table_creation_enabled               = var.services
        route_table_gateway_firewall_route_enabled = var.services
        express_route = {
          express_route_circuits = {
            "primary/one" = {
              id = "${local.parent_id}/providers/Microsoft.Network/expressRouteCircuits/${hub_key}"
              connection = {
                name       = "con-${hub_key}-erc"
                shared_key = local.keys.er_connection
              }
              peering = {
                peering_type                  = "AzurePrivatePeering"
                vlan_id                       = 101
                peer_asn                      = 65001
                primary_peer_address_prefix   = "172.16.0.0/30"
                secondary_peer_address_prefix = "172.16.0.4/30"
                shared_key                    = local.keys.er_peering
              }
            }
          }
          local_network_gateways = {
            "existing:one" = {
              id = "${local.parent_id}/providers/Microsoft.Network/localNetworkGateways/${hub_key}-existing"
              connection = {
                name       = "con-${hub_key}-existing"
                type       = "IPsec"
                shared_key = local.keys.er_local
              }
            }
          }
        }
        vpn = {
          local_network_gateways = {
            "office:one" = {
              name            = "lgw-${hub_key}-office"
              gateway_address = "192.0.2.1"
              address_space   = ["10.20.0.0/16"]
              connection = {
                name       = "con-${hub_key}-office"
                type       = "IPsec"
                shared_key = local.keys.vpn_connection
              }
            }
          }
        }
      }
    }
  }
}