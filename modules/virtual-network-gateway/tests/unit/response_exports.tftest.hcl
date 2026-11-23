mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      output = {
        properties = {
          bgpSettings = {
            asn = 65515
          }
        }
      }
    }
  }
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "azurerm" {}

run "gateway_exports_only_properties_used_by_outputs" {
  command = apply

  variables {
    enable_telemetry                  = false
    location                          = "centralindia"
    name                              = "gateway-export-test"
    parent_id                         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/gateway-export-test"
    subnet_creation_enabled           = false
    virtual_network_gateway_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/gateway-export-test/providers/Microsoft.Network/virtualNetworks/hub/subnets/GatewaySubnet"
  }

  assert {
    condition     = length(azapi_resource.vgw.response_export_values) == 1 && azapi_resource.vgw.response_export_values[0] == "properties.bgpSettings"
    error_message = "Export only BGP settings, not volatile P2S health or ETags that can change between plan and apply."
  }

  assert {
    condition     = output.virtual_network_gateway.bgp_settings.asn == 65515
    error_message = "The curated gateway output must retain the exported BGP settings."
  }

  assert {
    condition     = output.virtual_network_gateway.name == "gateway-export-test" && output.virtual_network_gateway.id == output.resource_id
    error_message = "The gateway name and ID outputs must remain unchanged."
  }
}
