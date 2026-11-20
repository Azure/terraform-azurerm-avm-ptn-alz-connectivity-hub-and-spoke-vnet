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

variables {
  enable_telemetry                  = false
  location                          = "eastus"
  name                              = "vgw-test"
  parent_id                         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
  subnet_creation_enabled           = false
  tags                              = {}
  virtual_network_gateway_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/GatewaySubnet"
  ip_configurations = {
    primary = {
      name = "gateway-ip"
      public_ip = {
        creation_enabled = false
        id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/publicIPAddresses/pip-test"
      }
    }
  }
}

run "vpn_accepts_null_scale_inputs" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    type                         = "Vpn"
    sku                          = "VpnGw1"
    vpn_active_active_enabled    = false
    express_route_scale_unit_min = null
    express_route_scale_unit_max = null
  }

  assert {
    condition     = !contains(keys(azapi_resource.vgw.body.properties), "autoScaleConfiguration")
    error_message = "VPN gateways must plan with omitted scale inputs and must not emit ExpressRoute autoscale configuration."
  }
}

run "legacy_express_route_omits_scaling" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  assert {
    condition     = !contains(keys(azapi_resource.vgw.body.properties), "autoScaleConfiguration")
    error_message = "The default ExpressRoute SKU must not emit autoscale configuration."
  }
}

run "scale_defaults_to_fixed_one" {
  command = apply

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    sku = "ErGwScale"
  }

  assert {
    condition     = azapi_resource.vgw.body.properties.autoScaleConfiguration.bounds == { min = 1, max = 1 }
    error_message = "ErGwScale must default to a fixed one-unit gateway."
  }
}

run "scale_null_uses_fixed_defaults" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    sku                          = "ErGwScale"
    express_route_scale_unit_min = null
    express_route_scale_unit_max = null
  }

  assert {
    condition     = azapi_resource.vgw.body.properties.autoScaleConfiguration.bounds == { min = 1, max = 1 }
    error_message = "Explicit null scale inputs must use the documented defaults."
  }
}

run "autoscale_emits_requested_bounds" {
  command = apply

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    sku                          = "ErGwScale"
    express_route_scale_unit_min = 2
    express_route_scale_unit_max = 10
  }

  assert {
    condition     = azapi_resource.vgw.body.properties.autoScaleConfiguration.bounds == { min = 2, max = 10 }
    error_message = "ErGwScale must forward the requested autoscale bounds without changing them."
  }

  assert {
    condition     = azapi_resource.vgw.body.properties.sku == { name = "ErGwScale", tier = "ErGwScale" }
    error_message = "The gateway SKU name and tier must both be ErGwScale."
  }
}

run "fixed_scale_accepts_upper_bound" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    sku                          = "ErGwScale"
    express_route_scale_unit_min = 40
    express_route_scale_unit_max = 40
  }

  assert {
    condition     = azapi_resource.vgw.body.properties.autoScaleConfiguration.bounds == { min = 40, max = 40 }
    error_message = "Fixed scaling must support the inclusive upper bound of 40 units."
  }
}

run "rejects_min_below_one" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    sku                          = "ErGwScale"
    express_route_scale_unit_min = 0
  }

  expect_failures = [var.express_route_scale_unit_min]
}

run "rejects_min_above_forty" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    sku                          = "ErGwScale"
    express_route_scale_unit_min = 41
  }

  expect_failures = [var.express_route_scale_unit_min]
}

run "rejects_max_below_one" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    sku                          = "ErGwScale"
    express_route_scale_unit_max = 0
  }

  expect_failures = [var.express_route_scale_unit_max]
}

run "rejects_max_above_forty" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    sku                          = "ErGwScale"
    express_route_scale_unit_min = 2
    express_route_scale_unit_max = 41
  }

  expect_failures = [var.express_route_scale_unit_max]
}

run "rejects_fractional_min" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    sku                          = "ErGwScale"
    express_route_scale_unit_min = 2.5
    express_route_scale_unit_max = 10
  }

  expect_failures = [var.express_route_scale_unit_min]
}

run "rejects_fractional_max" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    sku                          = "ErGwScale"
    express_route_scale_unit_min = 2
    express_route_scale_unit_max = 10.5
  }

  expect_failures = [var.express_route_scale_unit_max]
}

run "rejects_reversed_bounds" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    sku                          = "ErGwScale"
    express_route_scale_unit_min = 10
    express_route_scale_unit_max = 2
  }

  expect_failures = [azapi_resource.vgw]
}

run "rejects_autoscale_from_one" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    sku                          = "ErGwScale"
    express_route_scale_unit_min = 1
    express_route_scale_unit_max = 10
  }

  expect_failures = [azapi_resource.vgw]
}

run "parent_plans_scale_and_vpn_together" {
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
    hub_virtual_networks = {
      primary = {
        location          = "eastus"
        default_parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
        enabled_resources = {
          firewall             = false
          firewall_policy      = false
          bastion              = false
          private_dns_zones    = false
          private_dns_resolver = false
          dns_resolver_policy  = false
          nat_gateway          = false
        }
        virtual_network_gateways = {
          subnet_address_prefix = "10.0.0.0/27"
          express_route = {
            sku                          = "ErGwScale"
            express_route_scale_unit_min = 2
            express_route_scale_unit_max = 10
          }
          vpn = {
            vpn_active_active_enabled = false
          }
        }
      }
    }
  }

  assert {
    condition     = toset(keys(output.virtual_network_gateway_resource_ids)) == toset(["primary-express-route", "primary-vpn"])
    error_message = "The parent must plan both the ErGwScale and default-enabled VPN gateways."
  }

  assert {
    condition     = local.virtual_network_gateways["primary-express-route"].virtual_network_gateway.express_route_scale_unit_min == 2 && local.virtual_network_gateways["primary-express-route"].virtual_network_gateway.express_route_scale_unit_max == 10
    error_message = "The parent must preserve the configured ErGwScale bounds when preparing child-module inputs."
  }
}