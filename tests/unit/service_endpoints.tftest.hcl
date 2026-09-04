########################################################################################
# Unit tests for subnet Service Endpoints (ALZ issue #554 / VNet PR #130 contract).
#
# These tests exercise the public `hub_virtual_networks` subnet contract:
#   - the removed `service_endpoints_with_location` field must fail loudly
#     (guards against the silent-drop regression behind issue #554);
#   - the supported names-only `service_endpoints` field must be accepted.
#
# They are plan-only and use mocked providers, so no Azure resources are created.
# Run with: terraform test -test-directory=tests/unit
########################################################################################

mock_provider "azapi" {}
mock_provider "azurerm" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  enable_telemetry = false
}

# Negative: setting the removed `service_endpoints_with_location` field on a subnet
# must fail variable validation with the migration message, rather than being
# silently discarded during object type conversion.
run "reject_service_endpoints_with_location" {
  command = plan

  variables {
    hub_virtual_networks = {
      primary = {
        location          = "eastus"
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
        }
        default_hub_address_space = "192.168.0.0/16"
        hub_virtual_network = {
          address_space = ["192.168.0.0/24"]
          subnets = {
            workload = {
              name             = "snet-workload"
              address_prefixes = ["192.168.0.0/26"]
              service_endpoints_with_location = [
                {
                  service = "Microsoft.Storage"
                }
              ]
            }
          }
        }
      }
    }
  }

  expect_failures = [var.hub_virtual_networks]
}

# Positive: the supported names-only `service_endpoints` set is accepted and plans
# without error (all optional hub resources disabled to keep the plan lightweight).
run "accept_service_endpoints" {
  command = plan

  # Stub the regions utility module: its live azapi data source returns null under a
  # mocked provider, and no zone-dependent resources are enabled in this test.
  override_module {
    target = module.regions
    outputs = {
      regions_by_name = {
        eastus = {
          zones = ["1", "2", "3"]
        }
      }
    }
  }

  variables {
    hub_and_spoke_networks_settings = {
      enabled_resources = {
        ddos_protection_plan = false
      }
    }
    hub_virtual_networks = {
      primary = {
        location          = "eastus"
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
        }
        default_hub_address_space = "192.168.0.0/16"
        hub_virtual_network = {
          address_space = ["192.168.0.0/24"]
          subnets = {
            workload = {
              name              = "snet-workload"
              address_prefixes  = ["192.168.0.0/26"]
              service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
            }
          }
        }
      }
    }
  }

  # Pass-through: the requested service names must actually reach the child subnet
  # payload as `{ service = <name> }`. This directly guards the #554 silent-drop
  # failure mode, which a plain "plan succeeds" check cannot detect.
  assert {
    condition = toset([
      for se in module.hub_and_spoke_vnet.virtual_networks["primary"].subnets["primary-workload"].resource.body.properties.serviceEndpoints : se.service
    ]) == toset(["Microsoft.KeyVault", "Microsoft.Storage"])
    error_message = "Requested service_endpoints did not reach the child subnet payload."
  }
}

# Negative: no-endpoint subnets must remain valid (the validation must not require
# service_endpoints, only forbid the removed location-aware field).
run "no_endpoints_is_valid" {
  command = plan

  override_module {
    target = module.regions
    outputs = {
      regions_by_name = {
        eastus = {
          zones = ["1", "2", "3"]
        }
      }
    }
  }

  variables {
    hub_and_spoke_networks_settings = {
      enabled_resources = {
        ddos_protection_plan = false
      }
    }
    hub_virtual_networks = {
      primary = {
        location          = "eastus"
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
        }
        default_hub_address_space = "192.168.0.0/16"
        hub_virtual_network = {
          address_space = ["192.168.0.0/24"]
          subnets = {
            workload = {
              name             = "snet-workload"
              address_prefixes = ["192.168.0.0/26"]
            }
          }
        }
      }
    }
  }
}

# Negative: setting BOTH fields must also fail. The trigger is the legacy field
# being non-null, guarding against anyone weakening the rule to "only fail when
# service_endpoints is unset".
run "reject_both_fields_set" {
  command = plan

  variables {
    hub_virtual_networks = {
      primary = {
        location          = "eastus"
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
        }
        default_hub_address_space = "192.168.0.0/16"
        hub_virtual_network = {
          address_space = ["192.168.0.0/24"]
          subnets = {
            workload = {
              name              = "snet-workload"
              address_prefixes  = ["192.168.0.0/26"]
              service_endpoints = ["Microsoft.Storage"]
              service_endpoints_with_location = [
                {
                  service = "Microsoft.Storage"
                }
              ]
            }
          }
        }
      }
    }
  }

  expect_failures = [var.hub_virtual_networks]
}
