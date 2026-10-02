mock_provider "azurerm" {}
mock_provider "azapi" {}
mock_provider "random" {}
mock_provider "modtm" {}

run "sensitive_legacy_gateway_inputs" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    enable_telemetry                  = false
    location                          = "westeurope"
    name                              = "vgw-test"
    parent_id                         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
    sku                               = "ErGw1AZ"
    type                              = "ExpressRoute"
    subnet_creation_enabled           = false
    route_table_creation_enabled      = false
    virtual_network_gateway_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/GatewaySubnet"
    express_route_circuits = {
      primary = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/expressRouteCircuits/erc-test"
        connection = {
          name              = "custom-er-connection"
          authorization_key = sensitive("synthetic-authorization")
          routing_weight    = 25
          shared_key        = sensitive("erc-connection-key")
          tags              = { purpose = "shared-key-test" }
        }
        peering = {
          peering_type                  = "AzurePrivatePeering"
          vlan_id                       = 101
          peer_asn                      = 65001
          primary_peer_address_prefix   = "172.16.0.0/30"
          secondary_peer_address_prefix = "172.16.0.4/30"
          shared_key                    = sensitive("erc-peering-key")
        }
      }
      disabled = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/expressRouteCircuits/erc-disabled"
      }
    }
    local_network_gateways = {
      office = {
        gateway_address = "192.0.2.1"
        address_space   = ["10.20.0.0/16"]
        connection = {
          type       = "IPsec"
          shared_key = sensitive("office-connection-key")
        }
      }
    }
  }

  assert {
    condition     = toset(keys(azurerm_virtual_network_gateway_connection.vgw)) == toset(["erc-primary", "lgw-office"])
    error_message = "Legacy connection instance keys must remain unchanged."
  }

  assert {
    condition     = toset(keys(azurerm_express_route_circuit_peering.vgw)) == toset(["primary"]) && toset(keys(azurerm_local_network_gateway.vgw)) == toset(["office"])
    error_message = "Only configured peerings and local gateways should be created."
  }

  assert {
    condition = (
      azurerm_virtual_network_gateway_connection.vgw["erc-primary"].shared_key == "erc-connection-key" &&
      azurerm_virtual_network_gateway_connection.vgw["lgw-office"].shared_key == "office-connection-key" &&
      azurerm_express_route_circuit_peering.vgw["primary"].shared_key == "erc-peering-key"
    )
    error_message = "Every resource must read its original shared_key."
  }

  assert {
    condition = (
      issensitive(azurerm_virtual_network_gateway_connection.vgw["erc-primary"].shared_key) &&
      issensitive(azurerm_virtual_network_gateway_connection.vgw["lgw-office"].shared_key) &&
      issensitive(azurerm_express_route_circuit_peering.vgw["primary"].shared_key)
    )
    error_message = "Shared keys must retain sensitive metadata."
  }

  assert {
    condition = (
      azurerm_virtual_network_gateway_connection.vgw["erc-primary"].authorization_key == "synthetic-authorization" &&
      issensitive(azurerm_virtual_network_gateway_connection.vgw["erc-primary"].authorization_key) &&
      azurerm_virtual_network_gateway_connection.vgw["erc-primary"].name == "custom-er-connection" &&
      azurerm_virtual_network_gateway_connection.vgw["erc-primary"].routing_weight == 25 &&
      azurerm_virtual_network_gateway_connection.vgw["erc-primary"].tags.purpose == "shared-key-test"
    )
    error_message = "Index-based reads must preserve authorization secrecy and the original connection attributes."
  }
}

run "empty_optional_connections" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    enable_telemetry                  = false
    location                          = "westeurope"
    name                              = "vgw-test"
    parent_id                         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
    sku                               = "ErGw1AZ"
    type                              = "ExpressRoute"
    subnet_creation_enabled           = false
    route_table_creation_enabled      = false
    virtual_network_gateway_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/GatewaySubnet"
    express_route_circuits = sensitive({
      primary = {
        id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/expressRouteCircuits/erc-test"
        connection = null
        peering    = null
      }
    })
    local_network_gateways = sensitive({
      existing = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/localNetworkGateways/existing"
      }
    })
  }

  assert {
    condition = (
      length(azurerm_virtual_network_gateway_connection.vgw) == 0 &&
      length(azurerm_express_route_circuit_peering.vgw) == 0 &&
      length(azurerm_local_network_gateway.vgw) == 0
    )
    error_message = "Null or absent connections must not create connections, peerings or duplicate existing local gateways."
  }
}