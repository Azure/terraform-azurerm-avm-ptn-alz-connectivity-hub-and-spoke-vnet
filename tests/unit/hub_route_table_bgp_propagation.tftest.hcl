# Regression test for Azure/Azure-Landing-Zones#4021
#
# Verifies that hub user subnet route tables honor the
# route_table_user_subnets_bgp_propagation_enabled setting and that
# the default behavior remains enabled.

mock_provider "azurerm" {}
mock_provider "azapi" {}
mock_provider "random" {}
mock_provider "modtm" {}

run "bgp_route_propagation_can_be_disabled" {
  command = plan

  module {
    source = "./modules/hub-virtual-network-mesh"
  }

  variables {
    enable_telemetry = false

    hub_virtual_networks = {
      primary = {
        name          = "vnet-hub-test"
        address_space = ["10.0.0.0/16"]
        location      = "westeurope"
        parent_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test"

        route_table_user_subnets_enabled                 = true
        route_table_user_subnets_bgp_propagation_enabled = false
        hub_router_ip_address                            = "10.0.0.4"
      }
    }
  }

  assert {
    condition     = module.hub_routing_user_subnets["primary"].resource.bgp_route_propagation_enabled == false
    error_message = "Hub user subnet route table must disable BGP route propagation when route_table_user_subnets_bgp_propagation_enabled is false."
  }
}

run "bgp_route_propagation_defaults_to_enabled" {
  command = plan

  module {
    source = "./modules/hub-virtual-network-mesh"
  }

  variables {
    enable_telemetry = false

    hub_virtual_networks = {
      primary = {
        name          = "vnet-hub-test"
        address_space = ["10.0.0.0/16"]
        location      = "westeurope"
        parent_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test"

        route_table_user_subnets_enabled = true
        hub_router_ip_address            = "10.0.0.4"
      }
    }
  }

  assert {
    condition     = module.hub_routing_user_subnets["primary"].resource.bgp_route_propagation_enabled == true
    error_message = "Hub user subnet route table must keep BGP route propagation enabled by default."
  }
}

run "bgp_route_propagation_can_be_enabled" {
  command = plan

  module {
    source = "./modules/hub-virtual-network-mesh"
  }

  variables {
    enable_telemetry = false

    hub_virtual_networks = {
      primary = {
        name          = "vnet-hub-test"
        address_space = ["10.0.0.0/16"]
        location      = "westeurope"
        parent_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test"

        route_table_user_subnets_enabled                 = true
        route_table_user_subnets_bgp_propagation_enabled = true
        hub_router_ip_address                            = "10.0.0.4"
      }
    }
  }

  assert {
    condition     = module.hub_routing_user_subnets["primary"].resource.bgp_route_propagation_enabled == true
    error_message = "Hub user subnet route table must enable BGP route propagation when route_table_user_subnets_bgp_propagation_enabled is true."
  }
}
