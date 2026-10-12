# Regression test for Azure/Azure-Landing-Zones#4299.
# Verifies an imported hub VNet keeps its Azure-returned subnets and spoke peerings.

mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test/providers/Microsoft.Network/virtualNetworks/vnet-hub-test"
    }
  }
}

mock_provider "azurerm" {}
mock_provider "modtm" {}
mock_provider "random" {}

override_resource {
  target = module.hub_virtual_network_subnets["primary-app"].azapi_resource.subnet[0]
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test/providers/Microsoft.Network/virtualNetworks/vnet-hub-test/subnets/snet-app"
  }
}

variables {
  enable_telemetry = false

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
        }
      }
    }
  }
}

run "seed_imported_hub_state" {
  command   = apply
  state_key = "imported_hub"

  module {
    source = "./tests/unit/fixtures/imported_hub_state"
  }
}

run "first_post_import_plan" {
  command   = plan
  state_key = "imported_hub"

  module {
    source = "./modules/hub-virtual-network-mesh"
  }

  assert {
    condition     = try(jsonencode(module.hub_virtual_networks["primary"].resource.body.properties.subnets), "") == jsonencode(run.seed_imported_hub_state.imported_subnets)
    error_message = "The first plan after import must preserve the complete Azure-returned subnet collection."
  }

  assert {
    condition     = try(jsonencode(module.hub_virtual_networks["primary"].resource.body.properties.virtualNetworkPeerings), "") == jsonencode(run.seed_imported_hub_state.imported_peerings)
    error_message = "The first plan after import must preserve the complete spoke peering collection."
  }

  assert {
    condition = (
      module.hub_virtual_networks["primary"].resource_id == run.seed_imported_hub_state.virtual_network_resource_id &&
      module.hub_virtual_network_subnets["primary-app"].resource_id == run.seed_imported_hub_state.subnet_resource_id
    )
    error_message = "Adopting the imported state must preserve both the VNet and the independent subnet identities."
  }
}

run "apply_after_import" {
  command   = apply
  state_key = "imported_hub"

  module {
    source = "./modules/hub-virtual-network-mesh"
  }
}

run "tag_update_plan" {
  command   = plan
  state_key = "imported_hub"

  module {
    source = "./modules/hub-virtual-network-mesh"
  }

  variables {
    hub_virtual_networks = {
      primary = merge(var.hub_virtual_networks.primary, {
        tags = { regression = "after-import" }
      })
    }
  }

  assert {
    condition = (
      try(jsonencode(module.hub_virtual_networks["primary"].resource.body.properties.subnets), "") == jsonencode(run.seed_imported_hub_state.imported_subnets) &&
      try(jsonencode(module.hub_virtual_networks["primary"].resource.body.properties.virtualNetworkPeerings), "") == jsonencode(run.seed_imported_hub_state.imported_peerings) &&
      module.hub_virtual_networks["primary"].resource.tags.regression == "after-import"
    )
    error_message = "A later tag update must retain both imported child collections."
  }
}
