mock_provider "azurerm" {}
mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}
mock_provider "random" {}
mock_provider "modtm" {}

run "custom_default_retained_when_automatic_routing_disabled" {
  command = plan

  module {
    source = "./modules/hub-virtual-network-mesh"
  }

  variables {
    enable_telemetry = false

    hub_virtual_networks = {
      primary = {
        name                         = "vnet-hub-test"
        address_space                = ["10.0.0.0/16"]
        location                     = "westeurope"
        parent_id                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test"
        hub_router_ip_address        = "10.0.0.4"
        route_table_firewall_enabled = false
        route_table_entries_firewall = [{
          name                = "custom-default"
          address_prefix      = "0.0.0.0/0"
          next_hop_type       = "VirtualAppliance"
          next_hop_ip_address = "10.0.0.5"
        }]
      }
    }
  }

  assert {
    condition     = length(local.final_route_map_firewall) == 1 && length(local.default_route_internet) == 0
    error_message = "A caller default must remain in the ordinary route map when automatic firewall routing is disabled."
  }

  assert {
    condition     = try(local.final_route_map_firewall["custom-default"].next_hop_in_ip_address == "10.0.0.5", false)
    error_message = "The retained caller default must preserve its next-hop address."
  }

  assert {
    condition     = try(azurerm_route.firewall_mesh["custom-default"].route_table_name == "rt-firewall-primary", false)
    error_message = "The retained default must be attached to the caller's firewall route table."
  }
}

run "no_router" {
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
        route_table_entries_firewall = [{
          name           = "custom-default"
          address_prefix = "0.0.0.0/0"
          next_hop_type  = "None"
        }]
      }
    }
  }

  assert {
    condition     = length(azurerm_route.firewall_default) == 0 && length(azurerm_route.firewall_mesh) == 1
    error_message = "A custom default must still create a route without a firewall or router."
  }

  assert {
    condition     = try(azurerm_route.firewall_mesh["custom-default"].next_hop_type == "None", false)
    error_message = "The custom route must retain its next-hop type."
  }
}

run "generated_default" {
  command = plan

  module {
    source = "./modules/hub-virtual-network-mesh"
  }

  variables {
    enable_telemetry = false
    hub_virtual_networks = {
      primary = {
        name                  = "vnet-hub-test"
        address_space         = ["10.0.0.0/16"]
        location              = "westeurope"
        parent_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test"
        hub_router_ip_address = "10.0.0.4"
      }
    }
  }

  assert {
    condition     = length(azurerm_route.firewall_default) == 1 && length(azurerm_route.firewall_mesh) == 0
    error_message = "Without an override, automatic routing must keep exactly one generated default."
  }

  assert {
    condition     = azurerm_route.firewall_default["primary"].name == "internet" && azurerm_route.firewall_default["primary"].address_prefix == "0.0.0.0/0" && azurerm_route.firewall_default["primary"].next_hop_type == "Internet" && azurerm_route.firewall_default["primary"].next_hop_in_ip_address == null
    error_message = "The generated Internet default must retain its name, prefix, and next hop."
  }
}

run "override_default" {
  command = plan

  module {
    source = "./modules/hub-virtual-network-mesh"
  }

  override_resource {
    target          = azurerm_route.firewall_default["primary"]
    override_during = plan
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test/providers/Microsoft.Network/routeTables/rt-firewall-primary/routes/upstream-default"
    }
  }

  variables {
    enable_telemetry = false
    hub_virtual_networks = {
      primary = {
        name                  = "vnet-hub-test"
        address_space         = ["10.0.0.0/16"]
        location              = "westeurope"
        parent_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test"
        hub_router_ip_address = "10.0.0.4"
        route_table_entries_firewall = [{
          name                = "upstream-default"
          address_prefix      = "0.0.0.0/0"
          next_hop_type       = "VirtualAppliance"
          next_hop_ip_address = "10.0.0.5"
        }]
      }
    }
  }

  assert {
    condition     = length(azurerm_route.firewall_default) == 1 && length(azurerm_route.firewall_mesh) == 0
    error_message = "An override must replace the generated default without creating a duplicate route."
  }

  assert {
    condition     = azurerm_route.firewall_default["primary"].name == "upstream-default" && azurerm_route.firewall_default["primary"].next_hop_type == "VirtualAppliance" && azurerm_route.firewall_default["primary"].next_hop_in_ip_address == "10.0.0.5" && azurerm_route.firewall_default["primary"].route_table_name == "rt-firewall-primary"
    error_message = "The override must preserve its custom name, next hop, and firewall route table."
  }

  assert {
    condition     = local.firewall_route_table_ids["primary"] == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test/providers/Microsoft.Network/routeTables/rt-firewall-primary"
    error_message = "The subnet dependency must strip the custom route name from its route-table ID."
  }
}

run "reject_duplicate_defaults" {
  command = plan

  module {
    source = "./modules/hub-virtual-network-mesh"
  }

  variables {
    enable_telemetry = false
    hub_virtual_networks = {
      primary = {
        name                  = "vnet-hub-test"
        address_space         = ["10.0.0.0/16"]
        location              = "westeurope"
        parent_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test"
        hub_router_ip_address = "10.0.0.4"
        route_table_entries_firewall = [
          {
            name                = "first-default"
            address_prefix      = "0.0.0.0/0"
            next_hop_type       = "VirtualAppliance"
            next_hop_ip_address = "10.0.0.5"
          },
          {
            name                = "second-default"
            address_prefix      = "0.0.0.0/0"
            next_hop_type       = "VirtualAppliance"
            next_hop_ip_address = "10.0.0.6"
          }
        ]
      }
    }
  }

  expect_failures = [var.hub_virtual_networks]
}

run "defaults_are_scoped_per_hub" {
  command = plan

  module {
    source = "./modules/hub-virtual-network-mesh"
  }

  variables {
    enable_telemetry = false
    hub_virtual_networks = {
      for hub in ["primary", "secondary"] : hub => {
        name                  = "vnet-hub-${hub}"
        address_space         = hub == "primary" ? ["10.0.0.0/16"] : ["10.1.0.0/16"]
        location              = "westeurope"
        parent_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test"
        hub_router_ip_address = hub == "primary" ? "10.0.0.4" : "10.1.0.4"
        mesh_peering_enabled  = false
        route_table_entries_firewall = [{
          name                = "upstream-default"
          address_prefix      = "0.0.0.0/0"
          next_hop_type       = "VirtualAppliance"
          next_hop_ip_address = hub == "primary" ? "10.0.0.5" : "10.1.0.5"
        }]
      }
    }
  }

  assert {
    condition     = length(azurerm_route.firewall_default) == 2 && length(azurerm_route.firewall_mesh) == 0
    error_message = "Each hub must have exactly one custom default without a duplicate generated route."
  }

  assert {
    condition     = azurerm_route.firewall_default["primary"].name == "upstream-default" && azurerm_route.firewall_default["secondary"].name == "upstream-default" && azurerm_route.firewall_default["primary"].route_table_name != azurerm_route.firewall_default["secondary"].route_table_name && azurerm_route.firewall_default["primary"].next_hop_in_ip_address == "10.0.0.5" && azurerm_route.firewall_default["secondary"].next_hop_in_ip_address == "10.1.0.5"
    error_message = "Defaults with the same route name must retain independent route tables and next hops per hub."
  }
}