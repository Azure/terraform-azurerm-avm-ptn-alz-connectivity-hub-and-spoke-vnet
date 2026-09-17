# Unit test for the is_primary primary-region selection (Azure/Azure-Landing-Zones#4050).
# Verifies primary_region_key honors an explicit is_primary hub, otherwise falls back
# to the first hub key in alphabetical order, and rejects more than one primary hub.

mock_provider "azapi" {}
mock_provider "azurerm" {}
mock_provider "modtm" {}
mock_provider "random" {}

override_module {
  target = module.regions
  outputs = {
    regions_by_name = {
      southeastasia = {
        zones = ["1", "2", "3"]
      }
      swedencentral = {
        zones = ["1", "2", "3"]
      }
    }
  }
}

variables {
  enable_telemetry = false
}

run "defaults_to_alphabetically_first_hub" {
  command = plan

  variables {
    # Two hubs where the alphabetically-first key (southeastasia) is not the intended
    # primary region, and no is_primary is set - exercises the default behaviour.
    hub_virtual_networks = {
      southeastasia = {
        location          = "southeastasia"
        default_parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
        enabled_resources = {
          firewall                              = false
          firewall_policy                       = false
          bastion                               = false
          virtual_network_gateway_express_route = false
          virtual_network_gateway_vpn           = false
          private_dns_zones                     = false
          private_dns_resolver                  = false
          dns_resolver_policy                   = false
          nat_gateway                           = false
        }
      }
      swedencentral = {
        location          = "swedencentral"
        default_parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
        enabled_resources = {
          firewall                              = false
          firewall_policy                       = false
          bastion                               = false
          virtual_network_gateway_express_route = false
          virtual_network_gateway_vpn           = false
          private_dns_zones                     = false
          private_dns_resolver                  = false
          dns_resolver_policy                   = false
          nat_gateway                           = false
        }
      }
    }
  }

  assert {
    condition     = local.primary_region_key == "southeastasia"
    error_message = "With no is_primary hub, primary_region_key should fall back to the first hub key in alphabetical order (southeastasia)."
  }
}

run "is_primary_overrides_alphabetical_order" {
  command = plan

  variables {
    hub_virtual_networks = {
      southeastasia = {
        location          = "southeastasia"
        default_parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
        enabled_resources = {
          firewall                              = false
          firewall_policy                       = false
          bastion                               = false
          virtual_network_gateway_express_route = false
          virtual_network_gateway_vpn           = false
          private_dns_zones                     = false
          private_dns_resolver                  = false
          dns_resolver_policy                   = false
          nat_gateway                           = false
        }
      }
      swedencentral = {
        location          = "swedencentral"
        is_primary        = true
        default_parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
        enabled_resources = {
          firewall                              = false
          firewall_policy                       = false
          bastion                               = false
          virtual_network_gateway_express_route = false
          virtual_network_gateway_vpn           = false
          private_dns_zones                     = false
          private_dns_resolver                  = false
          dns_resolver_policy                   = false
          nat_gateway                           = false
        }
      }
    }
  }

  assert {
    condition     = local.primary_region_key == "swedencentral"
    error_message = "primary_region_key should be the hub explicitly marked is_primary (swedencentral), not the alphabetically-first key."
  }
}

run "rejects_multiple_primary_hubs" {
  command = plan

  variables {
    hub_virtual_networks = {
      southeastasia = {
        location          = "southeastasia"
        is_primary        = true
        default_parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
        enabled_resources = {
          firewall                              = false
          firewall_policy                       = false
          bastion                               = false
          virtual_network_gateway_express_route = false
          virtual_network_gateway_vpn           = false
          private_dns_zones                     = false
          private_dns_resolver                  = false
          dns_resolver_policy                   = false
          nat_gateway                           = false
        }
      }
      swedencentral = {
        location          = "swedencentral"
        is_primary        = true
        default_parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
        enabled_resources = {
          firewall                              = false
          firewall_policy                       = false
          bastion                               = false
          virtual_network_gateway_express_route = false
          virtual_network_gateway_vpn           = false
          private_dns_zones                     = false
          private_dns_resolver                  = false
          dns_resolver_policy                   = false
          nat_gateway                           = false
        }
      }
    }
  }

  expect_failures = [
    var.hub_virtual_networks,
  ]
}
