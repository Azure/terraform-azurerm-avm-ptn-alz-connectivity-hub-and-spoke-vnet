# Regression test for Azure/Azure-Landing-Zones#4299
#
# The VNet module 0.22.x rejects `service_endpoints_with_location`, so hub subnets
# pass names-only `service_endpoints` and map the deprecated input to service names.

mock_provider "azurerm" {}
mock_provider "azapi" {}
mock_provider "random" {}
mock_provider "modtm" {}

variables {
  enable_telemetry = false
}

run "service_endpoints_passed_through" {
  command = plan

  module {
    source = "./modules/hub-virtual-network-mesh"
  }

  variables {
    hub_virtual_networks = {
      primary = {
        name          = "vnet-hub-test"
        address_space = ["10.0.0.0/16"]
        location      = "westeurope"
        parent_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test"
        subnets = {
          app = {
            name              = "snet-app"
            address_prefixes  = ["10.0.1.0/24"]
            service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
          }
          none = {
            name             = "snet-none"
            address_prefixes = ["10.0.2.0/24"]
          }
        }
      }
    }
  }

  assert {
    condition     = local.subnets["primary-app"].service_endpoints == toset(["Microsoft.Storage", "Microsoft.Sql"])
    error_message = "service_endpoints must be passed through to the subnet module."
  }

  assert {
    condition     = try(length(local.subnets["primary-none"].service_endpoints), -1) == 0
    error_message = "service_endpoints must be an empty set, not null, when no service endpoint input is set."
  }
}

run "deprecated_service_endpoints_with_location_mapped_to_names" {
  command = plan

  module {
    source = "./modules/hub-virtual-network-mesh"
  }

  variables {
    hub_virtual_networks = {
      primary = {
        name          = "vnet-hub-test"
        address_space = ["10.0.0.0/16"]
        location      = "westeurope"
        parent_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test"
        subnets = {
          app = {
            name             = "snet-app"
            address_prefixes = ["10.0.1.0/24"]
            service_endpoints_with_location = [
              { service = "Microsoft.Storage", locations = ["westeurope"] },
              { service = "Microsoft.KeyVault" },
            ]
          }
        }
      }
    }
  }

  expect_failures = [
    check.service_endpoints_with_location_locations_ignored,
  ]

  assert {
    condition     = local.subnets["primary-app"].service_endpoints == toset(["Microsoft.Storage", "Microsoft.KeyVault"])
    error_message = "service_endpoints_with_location must be mapped to service names."
  }
}

run "both_service_endpoint_inputs_rejected" {
  command = plan

  variables {
    hub_virtual_networks = {
      primary = {
        location          = "westeurope"
        default_parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test"
        hub_virtual_network = {
          subnets = {
            app = {
              name                            = "snet-app"
              address_prefixes                = ["10.0.1.0/24"]
              service_endpoints               = ["Microsoft.Storage"]
              service_endpoints_with_location = [{ service = "Microsoft.Storage" }]
            }
          }
        }
      }
    }
  }

  expect_failures = [
    var.hub_virtual_networks,
  ]
}
