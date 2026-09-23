mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      subscription_id = "00000000-0000-0000-0000-000000000000"
      tenant_id       = "00000000-0000-0000-0000-000000000000"
      client_id       = "00000000-0000-0000-0000-000000000000"
      object_id       = "00000000-0000-0000-0000-000000000000"
    }
  }
}
mock_provider "azapi" {
  mock_data "azapi_resource_action" {
    defaults = {
      output = {
        value = [{
          name        = "westeurope"
          displayName = "West Europe"
          metadata = {
            geography      = "Europe"
            regionCategory = "Recommended"
            regionType     = "Physical"
            pairedRegion   = [{ name = "northeurope" }]
          }
          availabilityZoneMappings = [{ logicalZone = "1" }, { logicalZone = "2" }, { logicalZone = "3" }]
        }]
      }
    }
  }
}
mock_provider "random" {}
mock_provider "modtm" {}

# The fixture also re-exports every module output without `sensitive`, as the accelerator does.
run "unknown_direct_and_template" {
  command = plan

  module {
    source = "./tests/unit/fixtures/unknown_shared_keys"
  }

  assert {
    condition = alltrue([
      for result in [module.direct, nonsensitive(module.example.test_outputs)] : (
        keys(result.virtual_network_gateway_resource_ids) == ["primary-hub-express-route", "primary-hub-vpn", "secondary-hub-express-route", "secondary-hub-vpn"] &&
        keys(result.route_tables_gateway_resource_ids) == local.hub_keys &&
        keys(result.bastion_host_resource_ids) == local.hub_keys &&
        keys(result.nat_gateways) == local.hub_keys &&
        keys(result.private_link_private_dns_zones_maps) == local.hub_keys
      )
    ])
    error_message = "Unknown shared keys must not change the direct or templated resource identities."
  }

  assert {
    condition = alltrue([
      for result in [module.direct, nonsensitive(module.example.test_outputs)] : alltrue([
        for hub_key in local.hub_keys : (
          keys(result.nat_gateways[hub_key].public_ip_addresses) == ["primary"] &&
          result.private_link_private_dns_zones_maps[hub_key].fixture.virtual_network_links.custom.name == "custom-link"
        )
      ])
    ])
    error_message = "The complete graph must retain NAT IP and custom DNS link identities with unknown shared keys."
  }

  assert {
    condition     = issensitive(module.example.config_outputs) && issensitive(module.example.test_outputs) && !issensitive(keys(module.direct.virtual_network_gateway_resource_ids))
    error_message = "Secret-bearing aggregate outputs must stay protected while public instance keys stay usable."
  }
}