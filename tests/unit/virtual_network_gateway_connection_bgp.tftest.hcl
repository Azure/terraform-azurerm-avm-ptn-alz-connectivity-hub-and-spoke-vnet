# Regression test for Azure/Azure-Landing-Zones#4067.
#
# The public module interface continues to expose enable_bgp for backwards
# compatibility, while the AzureRM provider resource uses bgp_enabled.

mock_provider "azurerm" {}

mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

run "enable_bgp_maps_to_bgp_enabled" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    enable_telemetry = false

    location  = "eastus"
    name      = "vgw-test"
    parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"

    type                    = "Vpn"
    subnet_creation_enabled = false

    virtual_network_gateway_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/GatewaySubnet"

    local_network_gateways = {
      test = {
        gateway_address = "192.0.2.1"

        connection = {
          type       = "IPsec"
          enable_bgp = true
        }
      }
    }
  }

  assert {
    condition     = azurerm_virtual_network_gateway_connection.vgw["lgw-test"].bgp_enabled == true
    error_message = "enable_bgp input was not forwarded to the AzureRM bgp_enabled argument."
  }
}