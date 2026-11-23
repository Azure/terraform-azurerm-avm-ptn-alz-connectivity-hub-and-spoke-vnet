# Regression test for Azure/Azure-Landing-Zones#4029: connections must refresh without reading the shared key.

mock_provider "azurerm" {}

mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

variables {
  enable_telemetry = false

  location  = "eastus"
  name      = "vgw-test"
  parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"

  subnet_creation_enabled           = false
  virtual_network_gateway_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/GatewaySubnet"
}

run "express_route_connection_is_azapi" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    type = "ExpressRoute"

    express_route_circuits = {
      primary = {
        id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/expressRouteCircuits/erc-test"
        connection = {}
      }
    }
  }

  assert {
    condition     = azapi_resource.vgw_connection["erc-primary"].type == "Microsoft.Network/connections@2024-07-01"
    error_message = "The ExpressRoute connection must be an AzAPI Microsoft.Network/connections resource."
  }

  assert {
    condition     = azapi_resource.vgw_connection["erc-primary"].body.properties.connectionType == "ExpressRoute"
    error_message = "The connection type was not forwarded as connectionType."
  }

  assert {
    condition     = azapi_resource.vgw_connection["erc-primary"].body.properties.peer.id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/expressRouteCircuits/erc-test"
    error_message = "The ExpressRoute circuit ID was not forwarded as the peer ID."
  }

  assert {
    condition     = length(azapi_resource.vgw_connection["erc-primary"].sensitive_body_version) == 0
    error_message = "An ExpressRoute connection without keys must not set a sensitive body version."
  }
}

run "shared_key_is_write_only_with_digest_version" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    type = "Vpn"

    local_network_gateways = {
      test = {
        gateway_address = "192.0.2.1"

        connection = {
          type       = "IPsec"
          shared_key = "unit-test-shared-key"
        }
      }
    }
  }

  assert {
    condition     = try(azapi_resource.vgw_connection["lgw-test"].body.properties.sharedKey, null) == null
    error_message = "The shared key must not be part of the stored connection body."
  }

  assert {
    condition     = azapi_resource.vgw_connection["lgw-test"].sensitive_body_version["properties.sharedKey"] == sha256("unit-test-shared-key")
    error_message = "A changed shared key must change the sensitive body version so it is sent to Azure."
  }
}

run "connection_in_another_resource_group_uses_that_parent" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    type = "Vpn"

    local_network_gateways = {
      test = {
        gateway_address = "192.0.2.1"

        connection = {
          type                = "IPsec"
          resource_group_name = "rg-other"
        }
      }
    }
  }

  assert {
    condition     = azapi_resource.vgw_connection["lgw-test"].parent_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-other"
    error_message = "The connection must be created in the resource group given on the connection."
  }
}

run "ipsec_policy_defaults_match_the_removed_azurerm_defaults" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    type = "Vpn"

    local_network_gateways = {
      test = {
        gateway_address = "192.0.2.1"

        connection = {
          type = "IPsec"

          ipsec_policy = {
            dh_group         = "DHGroup14"
            ike_encryption   = "AES256"
            ike_integrity    = "SHA256"
            ipsec_encryption = "AES256"
            ipsec_integrity  = "SHA256"
            pfs_group        = "None"
          }
        }
      }
    }
  }

  assert {
    condition     = azapi_resource.vgw_connection["lgw-test"].body.properties.ipsecPolicies[0].saDataSizeKilobytes == 102400000
    error_message = "A missing sa_datasize must default to 102400000 KB as the AzureRM resource did."
  }

  assert {
    condition     = azapi_resource.vgw_connection["lgw-test"].body.properties.ipsecPolicies[0].saLifeTimeSeconds == 27000
    error_message = "A missing sa_lifetime must default to 27000 seconds as the AzureRM resource did."
  }
}

run "express_route_authorization_key_is_write_only_with_digest_version" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    type = "ExpressRoute"

    express_route_circuits = {
      primary = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/expressRouteCircuits/erc-test"

        connection = {
          authorization_key = "unit-test-authorization-key"
        }
      }
    }
  }

  assert {
    condition     = try(azapi_resource.vgw_connection["erc-primary"].body.properties.authorizationKey, null) == null
    error_message = "The authorization key must not be part of the stored connection body."
  }

  assert {
    condition     = azapi_resource.vgw_connection["erc-primary"].sensitive_body_version["properties.authorizationKey"] == sha256("unit-test-authorization-key")
    error_message = "A changed authorization key must change the sensitive body version."
  }
}

run "custom_bgp_addresses_follow_the_ip_configuration_that_holds_the_address" {
  command = apply

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    type             = "Vpn"
    vpn_bgp_enabled  = true
    vpn_bgp_settings = { asn = 65010 }

    ip_configurations = {
      "001" = {
        name            = "ipc-one"
        apipa_addresses = ["169.254.21.1"]
        public_ip       = { creation_enabled = false, id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/publicIPAddresses/pip-one" }
      }
      "002" = {
        name            = "ipc-two"
        apipa_addresses = ["169.254.22.1"]
        public_ip       = { creation_enabled = false, id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/publicIPAddresses/pip-two" }
      }
    }

    local_network_gateways = {
      test = {
        gateway_address = "192.0.2.1"

        connection = {
          type       = "IPsec"
          enable_bgp = true

          custom_bgp_addresses = {
            primary   = "169.254.22.1"
            secondary = "169.254.21.1"
          }
        }
      }
    }
  }

  assert {
    condition     = endswith(azapi_resource.vgw_connection["lgw-test"].body.properties.gatewayCustomBgpIpAddresses[0].ipConfigurationId, "/ipConfigurations/ipc-two")
    error_message = "The primary custom BGP address must use the IP configuration that holds it."
  }

  assert {
    condition     = endswith(azapi_resource.vgw_connection["lgw-test"].body.properties.gatewayCustomBgpIpAddresses[1].ipConfigurationId, "/ipConfigurations/ipc-one")
    error_message = "The secondary custom BGP address must use the IP configuration that holds it."
  }
}
run "custom_bgp_addresses_are_ignored_when_connection_bgp_is_disabled" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    type = "Vpn"

    local_network_gateways = {
      test = {
        gateway_address = "192.0.2.1"

        connection = {
          type       = "IPsec"
          enable_bgp = false

          custom_bgp_addresses = {
            primary   = "169.254.99.1"
            secondary = "169.254.99.2"
          }
        }
      }
    }
  }

  assert {
    condition     = try(azapi_resource.vgw_connection["lgw-test"].body.properties.gatewayCustomBgpIpAddresses, null) == null
    error_message = "Custom BGP addresses must not be sent, or looked up, while connection BGP is disabled."
  }
}

run "blank_shared_key_is_treated_as_unset_and_digests_are_sensitive" {
  command = plan

  module {
    source = "./modules/virtual-network-gateway"
  }

  variables {
    type = "Vpn"

    local_network_gateways = {
      blank = {
        gateway_address = "192.0.2.1"

        connection = {
          type       = "IPsec"
          shared_key = ""
        }
      }
      keyed = {
        gateway_address = "192.0.2.2"

        connection = {
          type       = "IPsec"
          shared_key = "unit-test-shared-key"
        }
      }
    }
  }

  assert {
    condition     = length(azapi_resource.vgw_connection["lgw-blank"].sensitive_body_version) == 0
    error_message = "A blank shared key must be treated as unset, as the AzureRM resource did."
  }

  assert {
    condition     = issensitive(azapi_resource.vgw_connection["lgw-keyed"].sensitive_body_version)
    error_message = "The key digest must be marked sensitive so it is redacted in plan output."
  }
}