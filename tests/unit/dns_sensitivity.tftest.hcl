mock_provider "azurerm" {}
mock_provider "azapi" {
  source = "./tests/unit/mocks"
}
mock_provider "random" {}
mock_provider "modtm" {}

variables {
  enable_telemetry = false
  tags             = {}
  hub_virtual_networks = {
    primary = {
      location          = "westeurope"
      default_parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-review"
      enabled_resources = {
        firewall                              = false
        firewall_policy                       = false
        private_dns_zones                     = true
        private_dns_resolver                  = false
        dns_resolver_policy                   = false
        bastion                               = false
        virtual_network_gateway_express_route = true
        virtual_network_gateway_vpn           = false
      }
      private_dns_zones = {
        private_link_private_dns_zones = {}
        private_link_private_dns_zones_additional = {
          fixture = { zone_name = "fixture.internal", private_dns_zone_supports_private_link = false }
        }
        virtual_network_link_default_virtual_networks = {
          custom = {
            virtual_network_resource_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-review/providers/Microsoft.Network/virtualNetworks/other"
            virtual_network_link_name_template_override = "custom-link"
          }
        }
      }
      virtual_network_gateways = {
        route_table_creation_enabled               = false
        route_table_gateway_firewall_route_enabled = false
        express_route = {
          express_route_circuits = {
            primary = {
              id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-review/providers/Microsoft.Network/expressRouteCircuits/lab"
              connection = { shared_key = sensitive("review-synthetic-key") }
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

run "sensitive_shared_key" {
  command = plan

  assert {
    condition     = output.private_link_private_dns_zones_maps["primary"]["fixture"].virtual_network_links["custom"].name == "custom-link"
    error_message = "A sensitive shared key must not change custom DNS link identities."
  }
}

run "null_links" {
  command = plan

  variables {
    hub_virtual_networks = {
      for hub_key, hub in var.hub_virtual_networks : hub_key => merge(hub, {
        private_dns_zones = merge(hub.private_dns_zones, { virtual_network_link_default_virtual_networks = null })
      })
    }
  }

  assert {
    condition     = keys(output.private_link_private_dns_zones_maps["primary"]["fixture"].virtual_network_links) == ["primary"]
    error_message = "Null default links must preserve the existing implicit hub link."
  }
}

run "empty_links" {
  command = plan

  variables {
    hub_virtual_networks = {
      for hub_key, hub in var.hub_virtual_networks : hub_key => merge(hub, {
        private_dns_zones = merge(hub.private_dns_zones, { virtual_network_link_default_virtual_networks = {} })
      })
    }
  }

  assert {
    condition     = length(output.private_link_private_dns_zones_maps["primary"]["fixture"].virtual_network_links) == 0
    error_message = "An explicitly empty link map must not be replaced with default links."
  }
}

run "nested_links" {
  command = plan

  variables {
    hub_virtual_networks = {
      for hub_key, hub in var.hub_virtual_networks : hub_key => merge(hub, {
        private_dns_zones = merge(hub.private_dns_zones, {
          virtual_network_link_default_virtual_networks = {}
          virtual_network_link_by_zone_and_virtual_network = {
            fixture = { custom = { virtual_network_resource_id = hub.private_dns_zones.virtual_network_link_default_virtual_networks.custom.virtual_network_resource_id, name = "base-link" } }
          }
          virtual_network_link_overrides_by_zone_and_virtual_network = {
            fixture = { custom = { name = "nested-link" } }
          }
        })
      })
    }
  }

  assert {
    condition = (
      keys(output.private_link_private_dns_zones_maps["primary"]["fixture"].virtual_network_links) == ["custom"] &&
      output.private_link_private_dns_zones_maps["primary"]["fixture"].virtual_network_links["custom"].name == "nested-link"
    )
    error_message = "Nested DNS link keys and name overrides must survive a sensitive shared key."
  }
}

run "payload_marks" {
  command = plan

  override_module {
    target = module.private_dns_zones["primary"]
    outputs = {
      private_dns_zone_resource_ids      = {}
      private_link_private_dns_zones_map = {}
    }
  }

  variables {
    hub_virtual_networks = {
      for hub_key, hub in var.hub_virtual_networks : hub_key => merge(hub, {
        private_dns_zones = merge(hub.private_dns_zones, {
          virtual_network_link_default_virtual_networks = {
            custom = merge(hub.private_dns_zones.virtual_network_link_default_virtual_networks.custom, { resolution_policy = sensitive("NxDomainRedirect") })
          }
        })
      })
    }
  }

  assert {
    condition = (
      issensitive(local.private_dns_zones["primary"].virtual_network_link_default_virtual_networks.custom.resolution_policy) &&
      local.private_dns_zones["primary"].virtual_network_link_default_virtual_networks.custom.resolution_policy == "NxDomainRedirect"
    )
    error_message = "Public identity projection must preserve nonempty business value sensitivity and content."
  }
}