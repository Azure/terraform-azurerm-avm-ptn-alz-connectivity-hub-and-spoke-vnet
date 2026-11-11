terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
  }
}

locals {
  parent_id          = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test"
  virtual_network_id = "${local.parent_id}/providers/Microsoft.Network/virtualNetworks/vnet-hub-test"
}

# Body as returned by Azure on import: child subnets and spoke peerings are embedded.
resource "azapi_resource" "vnet" {
  location  = "westeurope"
  name      = "vnet-hub-test"
  parent_id = local.parent_id
  type      = "Microsoft.Network/virtualNetworks@2024-07-01"
  body = {
    properties = {
      addressSpace = {
        addressPrefixes = ["10.0.0.0/16"]
      }
      subnets = [
        {
          id   = "${local.virtual_network_id}/subnets/snet-app"
          name = "snet-app"
          type = "Microsoft.Network/virtualNetworks/subnets"
          properties = {
            addressPrefix = "10.0.1.0/24"
          }
        },
        {
          id   = "${local.virtual_network_id}/subnets/snet-unmanaged"
          name = "snet-unmanaged"
          type = "Microsoft.Network/virtualNetworks/subnets"
          properties = {
            addressPrefix = "10.0.2.0/24"
          }
        },
      ]
      virtualNetworkPeerings = [{
        id   = "${local.virtual_network_id}/virtualNetworkPeerings/hub-to-spoke"
        name = "hub-to-spoke"
        type = "Microsoft.Network/virtualNetworks/virtualNetworkPeerings"
        properties = {
          allowForwardedTraffic     = true
          allowGatewayTransit       = true
          allowVirtualNetworkAccess = true
          peeringState              = "Connected"
          remoteVirtualNetwork = {
            id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-spoke-test/providers/Microsoft.Network/virtualNetworks/vnet-spoke-test"
          }
          useRemoteGateways = false
        }
      }]
    }
  }
  response_export_values = []
  tags                   = {}
}

output "resource" {
  description = "The synthetic imported virtual network."
  value       = azapi_resource.vnet
}

output "resource_id" {
  description = "The synthetic virtual network resource ID."
  value       = azapi_resource.vnet.id
}
