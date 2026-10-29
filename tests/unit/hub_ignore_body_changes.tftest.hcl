# Covers the ignore_body_changes interface added with the VNet module 0.22.2 upgrade.
# The value is write-only provider state, so assertions target the resolved per-subnet paths.

mock_provider "azurerm" {}
mock_provider "azapi" {}
mock_provider "random" {}
mock_provider "modtm" {}

variables {
  enable_telemetry = false

  hub_virtual_networks = {
    primary = {
      name          = "vnet-hub-test"
      address_space = ["10.0.0.0/16"]
      location      = "westeurope"
      parent_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test"
      subnets = {
        shared = {
          name             = "snet-shared"
          address_prefixes = ["10.0.1.0/24"]
        }
        override = {
          name                = "snet-override"
          address_prefixes    = ["10.0.2.0/24"]
          ignore_body_changes = ["properties.networkSecurityGroup"]
        }
        opt_out = {
          name                = "snet-opt-out"
          address_prefixes    = ["10.0.3.0/24"]
          ignore_body_changes = []
        }
      }
    }
    secondary = {
      name          = "vnet-hub-test-2"
      address_space = ["10.1.0.0/16"]
      location      = "northeurope"
      parent_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test"
    }
  }
}

run "defaults_to_no_ignored_paths" {
  command = plan

  module {
    source = "./modules/hub-virtual-network-mesh"
  }

  assert {
    condition     = length(local.subnets["primary-shared"].ignore_body_changes) == 0
    error_message = "Subnets must not ignore any body path by default."
  }
}

run "per_subnet_value_takes_precedence" {
  command = plan

  module {
    source = "./modules/hub-virtual-network-mesh"
  }

  variables {
    ignore_body_changes = {
      virtual_networks = ["tags"]
      virtual_networks_subnets = {
        virtual_networks_subnets = ["properties.routeTable"]
      }
      virtual_networks_virtual_network_peerings = {
        virtual_networks_virtual_network_peerings = ["properties.allowForwardedTraffic"]
      }
    }
  }

  assert {
    condition     = local.subnets["primary-shared"].ignore_body_changes == tolist(["properties.routeTable"])
    error_message = "Subnets without their own value must inherit the shared virtual_networks_subnets paths."
  }

  assert {
    condition     = local.subnets["primary-override"].ignore_body_changes == tolist(["properties.networkSecurityGroup"])
    error_message = "A per-subnet ignore_body_changes value must take precedence over the shared value."
  }

  assert {
    condition     = try(length(local.subnets["primary-opt_out"].ignore_body_changes), -1) == 0
    error_message = "An explicit empty per-subnet ignore_body_changes must take precedence over the shared value so the subnet stays fully reconciled."
  }

  assert {
    condition     = length(module.hub_virtual_network_peering) == 2
    error_message = "Supplying peering ignore_body_changes must not change the mesh peerings."
  }
}

run "root_preserves_omitted_and_empty_per_subnet_values" {
  command = plan

  variables {
    hub_and_spoke_networks_settings = {
      enabled_resources = {
        ddos_protection_plan = false
      }
    }
    hub_virtual_networks = {
      primary = {
        location          = "westeurope"
        default_parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test"
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
        hub_virtual_network = {
          address_space = ["10.0.0.0/16"]
          subnets = {
            inherit = {
              name             = "snet-inherit"
              address_prefixes = ["10.0.1.0/24"]
            }
            opt_out = {
              name                = "snet-opt-out"
              address_prefixes    = ["10.0.2.0/24"]
              ignore_body_changes = []
            }
          }
        }
      }
    }
  }

  assert {
    condition     = local.hub_virtual_networks["primary"].subnets["inherit"].ignore_body_changes == null
    error_message = "An omitted per-subnet ignore_body_changes must reach the mesh module as null so the subnet inherits the shared paths."
  }

  assert {
    condition     = try(length(local.hub_virtual_networks["primary"].subnets["opt_out"].ignore_body_changes), -1) == 0
    error_message = "An explicit empty per-subnet ignore_body_changes must reach the mesh module as an empty list, not null."
  }
}

run "root_rejects_empty_path" {
  command = plan

  variables {
    hub_virtual_networks = {}
    ignore_body_changes = {
      virtual_networks_subnets = {
        virtual_networks_subnets = [" "]
      }
    }
  }

  expect_failures = [
    var.ignore_body_changes,
  ]
}
