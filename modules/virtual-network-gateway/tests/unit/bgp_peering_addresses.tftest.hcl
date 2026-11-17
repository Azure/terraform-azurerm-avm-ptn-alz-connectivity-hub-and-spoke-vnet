mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}
mock_provider "azurerm" {}

variables {
  enable_telemetry                  = false
  location                          = "westeurope"
  name                              = "vgw-test"
  parent_id                         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
  sku                               = "VpnGw1AZ"
  subnet_creation_enabled           = false
  virtual_network_gateway_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/GatewaySubnet"
  type                              = "Vpn"
  vpn_active_active_enabled         = true
  vpn_bgp_enabled                   = true
  ip_configurations = {
    one = { name = "ipconfig-one" }
    two = { name = "ipconfig-two" }
  }
}

run "no_custom_apipa_omits_peering_addresses" {
  command = plan

  variables {
    vpn_bgp_settings = {
      asn         = 65542
      peer_weight = 0
    }
  }

  assert {
    condition     = !contains(keys(azapi_resource.vgw.body.properties.bgpSettings), "bgpPeeringAddresses")
    error_message = "bgpPeeringAddresses must be omitted when no custom APIPA addresses are configured."
  }
}

run "explicit_empty_apipa_lists_are_sent" {
  command = plan

  variables {
    vpn_bgp_settings = {
      asn         = 65542
      peer_weight = 0
    }
    ip_configurations = {
      one = { name = "ipconfig-one", apipa_addresses = [] }
      two = { name = "ipconfig-two", apipa_addresses = [] }
    }
  }

  assert {
    condition     = length(azapi_resource.vgw.body.properties.bgpSettings.bgpPeeringAddresses) == 2
    error_message = "An explicit empty APIPA list must still send an entry per IP configuration so that custom addresses can be cleared."
  }

  assert {
    condition = alltrue([
      for address in azapi_resource.vgw.body.properties.bgpSettings.bgpPeeringAddresses :
      length(address.customBgpIpAddresses) == 0
    ])
    error_message = "Entries for explicit empty APIPA lists must carry no custom addresses."
  }
}

run "custom_apipa_addresses_are_sent" {
  command = plan

  variables {
    vpn_bgp_settings = {
      asn         = 65542
      peer_weight = 0
    }
    ip_configurations = {
      one = { name = "ipconfig-one", apipa_addresses = ["169.254.21.1"] }
      two = { name = "ipconfig-two", apipa_addresses = ["169.254.21.2"] }
    }
  }

  assert {
    condition = [
      for address in azapi_resource.vgw.body.properties.bgpSettings.bgpPeeringAddresses : address.customBgpIpAddresses[0]
    ] == ["169.254.21.1", "169.254.21.2"]
    error_message = "Each IP configuration must send its own custom APIPA address."
  }

  assert {
    condition = [
      for address in azapi_resource.vgw.body.properties.bgpSettings.bgpPeeringAddresses : basename(address.ipconfigurationId)
    ] == ["ipconfig-one", "ipconfig-two"]
    error_message = "Each entry must reference its own IP configuration."
  }
}

run "set_and_unset_apipa_configurations_keep_every_entry" {
  command = plan

  variables {
    vpn_bgp_settings = {
      asn         = 65542
      peer_weight = 0
    }
    ip_configurations = {
      one = { name = "ipconfig-one", apipa_addresses = ["169.254.21.1"] }
      two = { name = "ipconfig-two" }
    }
  }

  assert {
    condition     = length(azapi_resource.vgw.body.properties.bgpSettings.bgpPeeringAddresses) == 2
    error_message = "An unset APIPA configuration must keep its entry when another one sets addresses, so the list matches what Azure returns."
  }

  assert {
    condition     = length(azapi_resource.vgw.body.properties.bgpSettings.bgpPeeringAddresses[1].customBgpIpAddresses) == 0
    error_message = "The unset configuration must send an empty custom address list."
  }
}

run "mixed_apipa_configuration_keeps_every_entry" {
  command = plan

  variables {
    vpn_bgp_settings = {
      asn         = 65542
      peer_weight = 0
    }
    ip_configurations = {
      one = { name = "ipconfig-one", apipa_addresses = ["169.254.21.1"] }
      two = { name = "ipconfig-two", apipa_addresses = [] }
    }
  }

  assert {
    condition     = length(azapi_resource.vgw.body.properties.bgpSettings.bgpPeeringAddresses) == 2
    error_message = "An IP configuration with an empty APIPA list must keep its entry when another one sets addresses."
  }
}

run "bgp_disabled_omits_bgp_settings" {
  command = plan

  variables {
    vpn_bgp_enabled = false
  }

  assert {
    condition     = !contains(keys(azapi_resource.vgw.body.properties), "bgpSettings")
    error_message = "bgpSettings must be omitted when BGP is disabled."
  }
}

run "unset_peer_weight_is_sent_as_zero" {
  command = plan

  variables {
    vpn_bgp_settings = {
      asn = 65542
    }
  }

  assert {
    condition     = lookup(azapi_resource.vgw.body.properties.bgpSettings, "peerWeight", null) == 0
    error_message = "An unset peer_weight must be sent as 0, the value Azure returns, not null."
  }
}

run "null_bgp_settings_use_defaults" {
  command = plan

  assert {
    condition     = azapi_resource.vgw.body.properties.bgpSettings.asn == 65515 && azapi_resource.vgw.body.properties.bgpSettings.peerWeight == 0
    error_message = "Without vpn_bgp_settings the gateway must be sent the default ASN and a peer weight of 0."
  }
}

run "explicit_peer_weight_is_preserved" {
  command = plan

  variables {
    vpn_bgp_settings = {
      asn         = 65542
      peer_weight = 5
    }
  }

  assert {
    condition     = azapi_resource.vgw.body.properties.bgpSettings.peerWeight == 5
    error_message = "An explicit peer_weight must be sent unchanged."
  }
}
