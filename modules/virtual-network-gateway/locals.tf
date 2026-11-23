locals {
  apipa_ip_configuration_names = merge([
    for ip_configuration in values(local.ip_configurations) : {
      for address in coalesce(ip_configuration.apipa_addresses, []) : address => ip_configuration.name
    }
  ]...)
  azurerm_express_route_circuit_peering           = nonsensitive(sensitive(local.express_route_circuit_peerings))
  azurerm_express_route_circuit_peering_sensitive = local.express_route_circuit_peerings
  azurerm_local_network_gateway = {
    for local_network_gateway_key, local_network_gateway in var.local_network_gateways : local_network_gateway_key => local_network_gateway
    if local_network_gateway.id == null
  }
  azurerm_public_ip = var.hosted_on_behalf_of_public_ip_enabled ? {} : {
    for ip_configuration_key, ip_configuration in local.ip_configurations : ip_configuration_key => {
      name                    = ip_configuration.public_ip.name
      resource_group_name     = ip_configuration.public_ip.resource_group_name
      allocation_method       = ip_configuration.public_ip.allocation_method
      sku                     = ip_configuration.public_ip.sku
      tags                    = ip_configuration.public_ip.tags
      zones                   = ip_configuration.public_ip.zones
      edge_zone               = ip_configuration.public_ip.edge_zone
      ddos_protection_mode    = ip_configuration.public_ip.ddos_protection_mode
      ddos_protection_plan_id = ip_configuration.public_ip.ddos_protection_plan_id
      domain_name_label       = ip_configuration.public_ip.domain_name_label
      idle_timeout_in_minutes = ip_configuration.public_ip.idle_timeout_in_minutes
      ip_tags                 = ip_configuration.public_ip.ip_tags
      ip_version              = ip_configuration.public_ip.ip_version
      public_ip_prefix_id     = ip_configuration.public_ip.public_ip_prefix_id
      reverse_fqdn            = ip_configuration.public_ip.reverse_fqdn
      sku_tier                = ip_configuration.public_ip.sku_tier
    }
    if ip_configuration.public_ip.creation_enabled == true
  }
  azurerm_virtual_network_gateway = {
    bgp_settings = {
      asn         = try(var.vpn_bgp_settings.asn, 65515)
      peer_weight = var.vpn_bgp_settings == null ? 0 : coalesce(var.vpn_bgp_settings.peer_weight, 0)
      peering_addresses = {
        for ip_configuration_key, ip_configuration in local.ip_configurations : ip_configuration_key => {
          ip_configuration_name = ip_configuration.name
          apipa_addresses       = ip_configuration.apipa_addresses == null ? [] : ip_configuration.apipa_addresses
        }
      }
    }
    ip_configuration = {
      for ip_configuration_key, ip_configuration in local.ip_configurations : ip_configuration_key => {
        name                          = ip_configuration.name
        public_ip_address_id          = var.hosted_on_behalf_of_public_ip_enabled ? null : (ip_configuration.public_ip.creation_enabled ? azurerm_public_ip.vgw[ip_configuration_key].id : ip_configuration.public_ip.id)
        subnet_id                     = var.subnet_creation_enabled ? azurerm_subnet.vgw[0].id : var.virtual_network_gateway_subnet_id
        private_ip_address_allocation = ip_configuration.private_ip_address_allocation
      }
    }
  }
  azurerm_virtual_network_gateway_connection = nonsensitive(sensitive(merge(
    local.local_network_gateway_virtual_network_gateway_connections,
    local.express_route_circuit_virtual_network_gateway_connections
  )))
  azurerm_virtual_network_gateway_connection_sensitive = merge(
    local.local_network_gateway_virtual_network_gateway_connections,
    local.express_route_circuit_virtual_network_gateway_connections
  )
  bgp_peering_addresses_enabled = anytrue([
    for ip_configuration in values(local.ip_configurations) : ip_configuration.apipa_addresses != null
  ])
  # Transform edge_zone string to extendedLocation object for AzAPI
  extended_location = var.edge_zone != null ? {
    name = var.edge_zone
    type = "EdgeZone"
  } : null
  virtual_network_gateway_connection_parent_ids = {
    for connection_key, connection in local.azurerm_virtual_network_gateway_connection : connection_key =>
    "/subscriptions/${provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.parent_id).subscription_id}/resourceGroups/${coalesce(connection.resource_group_name, local.resource_group_name)}"
  }
  virtual_network_gateway_connection_properties = {
    for connection_key, connection in local.azurerm_virtual_network_gateway_connection : connection_key => {
      for property, value in {
        connectionType                 = connection.type
        virtualNetworkGateway1         = { id = azapi_resource.vgw.id, properties = {} }
        connectionMode                 = try(connection.connection_mode, null)
        connectionProtocol             = try(connection.connection_protocol, null)
        dpdTimeoutSeconds              = try(connection.dpd_timeout_seconds, null)
        enableBgp                      = try(connection.enable_bgp, null)
        egressNatRules                 = try(connection.egress_nat_rule_ids, null) == null ? null : [for id in connection.egress_nat_rule_ids : { id = id }]
        ingressNatRules                = try(connection.ingress_nat_rule_ids, null) == null ? null : [for id in connection.ingress_nat_rule_ids : { id = id }]
        enablePrivateLinkFastPath      = try(connection.private_link_fast_path_enabled, null)
        expressRouteGatewayBypass      = try(connection.express_route_gateway_bypass, null)
        useLocalAzureIpAddress         = try(connection.local_azure_ip_address_enabled, null)
        usePolicyBasedTrafficSelectors = try(connection.use_policy_based_traffic_selectors, null)
        routingWeight                  = try(connection.routing_weight, null)
        localNetworkGateway2 = startswith(connection_key, "lgw-") ? {
          id         = try(azurerm_local_network_gateway.vgw[trimprefix(connection_key, "lgw-")].id, connection.local_network_gateway_id)
          properties = {}
        } : null
        peer                   = try(connection.express_route_circuit_id, null) == null ? null : { id = connection.express_route_circuit_id }
        virtualNetworkGateway2 = try(connection.peer_virtual_network_gateway_id, null) == null ? null : { id = connection.peer_virtual_network_gateway_id, properties = {} }
        gatewayCustomBgpIpAddresses = try(connection.enable_bgp, false) != true || try(connection.custom_bgp_addresses, null) == null ? null : [
          for address in [connection.custom_bgp_addresses.primary, connection.custom_bgp_addresses.secondary] : {
            ipConfigurationId  = "${azapi_resource.vgw.id}/ipConfigurations/${local.apipa_ip_configuration_names[address]}"
            customBgpIpAddress = address
          } if address != null && address != ""
        ]
        ipsecPolicies = try(connection.ipsec_policy, null) == null ? null : [{
          dhGroup             = connection.ipsec_policy.dh_group
          ikeEncryption       = connection.ipsec_policy.ike_encryption
          ikeIntegrity        = connection.ipsec_policy.ike_integrity
          ipsecEncryption     = connection.ipsec_policy.ipsec_encryption
          ipsecIntegrity      = connection.ipsec_policy.ipsec_integrity
          pfsGroup            = connection.ipsec_policy.pfs_group
          saDataSizeKilobytes = coalesce(connection.ipsec_policy.sa_datasize, 102400000)
          saLifeTimeSeconds   = coalesce(connection.ipsec_policy.sa_lifetime, 27000)
        }]
        trafficSelectorPolicies = try(connection.traffic_selector_policy, null) == null ? null : [
          for policy in connection.traffic_selector_policy : {
            localAddressRanges  = policy.local_address_prefixes
            remoteAddressRanges = policy.remote_address_prefixes
          }
        ]
      } : property => value if value != null
    }
  }
  virtual_network_gateway_connection_sensitive_properties = {
    for connection_key, connection in local.azurerm_virtual_network_gateway_connection_sensitive : connection_key => {
      for property, value in {
        authorizationKey = try(connection.authorization_key, null)
        sharedKey        = try(connection.shared_key, null)
      } : property => value if value != null && value != ""
    }
  }
  virtual_network_gateway_connection_sensitive_versions = {
    for connection_key, properties in local.virtual_network_gateway_connection_sensitive_properties : connection_key => sensitive({
      for property, value in properties : "properties.${property}" => sha256(value)
    })
  }
  virtual_network_gateway_properties = {
    # Common properties for all gateway types
    gatewayType = var.type
    sku = {
      name = var.sku
      tier = var.sku
    }
    # IP Configurations
    ipConfigurations = [
      for key, ip_config in local.azurerm_virtual_network_gateway.ip_configuration : {
        name = ip_config.name
        properties = merge(
          {
            privateIPAllocationMethod = ip_config.private_ip_address_allocation
            subnet = {
              id = ip_config.subnet_id
            }
          },
          ip_config.public_ip_address_id != null ? {
            publicIPAddress = {
              id = ip_config.public_ip_address_id
            }
          } : {}
        )
      }
    ]
    # Dynamic VPN-specific properties
    activeActive                    = var.type == "Vpn" && var.vpn_active_active_enabled == true ? true : false
    enableBgp                       = var.type == "Vpn" && var.vpn_bgp_enabled == true ? true : false
    vpnGatewayGeneration            = var.type == "Vpn" && var.vpn_generation != null ? var.vpn_generation : null
    enablePrivateIpAddress          = var.type == "Vpn" && var.vpn_private_ip_address_enabled == true ? true : false
    enableBgpRouteTranslationForNat = var.type == "Vpn" && var.vpn_bgp_route_translation_for_nat_enabled == true ? true : null
    enableDnsForwarding             = var.type == "Vpn" && var.vpn_dns_forwarding_enabled == true ? true : null
    disableIPSecReplayProtection    = var.type == "Vpn" && var.vpn_ip_sec_replay_protection_enabled == false ? true : null
    # VPN gateway default site
    gatewayDefaultSite = var.type == "Vpn" && var.vpn_default_local_network_gateway_id != null ? {
      id = var.vpn_default_local_network_gateway_id
    } : null
    # BGP Settings
    bgpSettings = var.type == "Vpn" && var.vpn_bgp_enabled == true ? {
      for key, value in {
        asn        = local.azurerm_virtual_network_gateway.bgp_settings.asn
        peerWeight = local.azurerm_virtual_network_gateway.bgp_settings.peer_weight
        bgpPeeringAddresses = local.bgp_peering_addresses_enabled ? [
          for key, peering_addr in local.azurerm_virtual_network_gateway.bgp_settings.peering_addresses : {
            ipconfigurationId    = "${var.parent_id}/providers/Microsoft.Network/virtualNetworkGateways/${var.name}/ipConfigurations/${peering_addr.ip_configuration_name}"
            customBgpIpAddresses = peering_addr.apipa_addresses
          }
        ] : null
      } : key => value if value != null
    } : null
    # Custom Routes
    customRoutes = var.type == "Vpn" && var.vpn_custom_route != null ? {
      addressPrefixes = var.vpn_custom_route.address_prefixes
    } : null
    # VPN Client Configuration
    vpnClientConfiguration = var.type == "Vpn" && var.vpn_point_to_site != null ? {
      vpnClientAddressPool = {
        addressPrefixes = var.vpn_point_to_site.address_space
      }
      vpnClientProtocols     = var.vpn_point_to_site.vpn_client_protocols
      vpnAuthenticationTypes = var.vpn_point_to_site.vpn_auth_types

      # AAD Authentication
      aadTenant   = var.vpn_point_to_site.aad_tenant
      aadAudience = var.vpn_point_to_site.aad_audience
      aadIssuer   = var.vpn_point_to_site.aad_issuer

      # RADIUS Authentication
      radiusServerAddress = var.vpn_point_to_site.radius_server_address
      radiusServerSecret  = var.vpn_point_to_site.radius_server_secret
      radiusServers = [
        for radius_server in var.vpn_point_to_site.radius_servers : {
          radiusServerAddress = radius_server.address
          radiusServerScore   = radius_server.score
          radiusServerSecret  = radius_server.secret
        }
      ]

      # IPSec Policy
      vpnClientIpsecPolicies = var.vpn_point_to_site.ipsec_policy != null ? [{
        dhGroup             = var.vpn_point_to_site.ipsec_policy.dh_group
        ikeEncryption       = var.vpn_point_to_site.ipsec_policy.ike_encryption
        ikeIntegrity        = var.vpn_point_to_site.ipsec_policy.ike_integrity
        ipsecEncryption     = var.vpn_point_to_site.ipsec_policy.ipsec_encryption
        ipsecIntegrity      = var.vpn_point_to_site.ipsec_policy.ipsec_integrity
        pfsGroup            = var.vpn_point_to_site.ipsec_policy.pfs_group
        saDataSizeKilobytes = var.vpn_point_to_site.ipsec_policy.sa_data_size_in_kilobytes
        saLifeTimeSeconds   = var.vpn_point_to_site.ipsec_policy.sa_lifetime_in_seconds
      }] : []

      # Root Certificates
      vpnClientRootCertificates = [
        for root_cert in var.vpn_point_to_site.root_certificates : {
          name = root_cert.name
          properties = {
            publicCertData = root_cert.public_cert_data
          }
        }
      ]

      # Revoked Certificates
      vpnClientRevokedCertificates = [
        for revoked_cert in var.vpn_point_to_site.revoked_certificates : {
          name = revoked_cert.name
          properties = {
            thumbprint = revoked_cert.thumbprint
          }
        }
      ]

      # Virtual Network Gateway Client Connections
      vngClientConnectionConfigurations = [
        for client_conn in var.vpn_point_to_site.virtual_network_gateway_client_connections : {
          name = client_conn.name
          properties = {
            vpnClientAddressPool = {
              addressPrefixes = client_conn.address_prefixes
            }
            virtualNetworkGatewayPolicyGroups = [
              for policy_group_name in client_conn.policy_group_names : {
                id = "${var.parent_id}/providers/Microsoft.Network/virtualNetworkGateways/${var.name}/virtualNetworkGatewayPolicyGroups/${policy_group_name}"
              }
            ]
          }
        }
      ]
    } : null
    # VPN Policy Groups
    virtualNetworkGatewayPolicyGroups = var.type == "Vpn" && length(var.vpn_policy_groups) > 0 ? [
      for policy_group in var.vpn_policy_groups : {
        name = policy_group.name
        properties = {
          isDefault = policy_group.is_default
          priority  = policy_group.priority
          policyMembers = [
            for policy_member in policy_group.policy_members : {
              name           = policy_member.name
              attributeType  = policy_member.type
              attributeValue = policy_member.value
            }
          ]
        }
      }
    ] : null
    # VPN Type
    vpnType = var.vpn_type
    # Express Route specific properties
    allowRemoteVnetTraffic = var.type == "ExpressRoute" ? var.express_route_remote_vnet_traffic_enabled : null
    allowVirtualWanTraffic = var.type == "ExpressRoute" ? var.express_route_virtual_wan_traffic_enabled : null
  }
  # Filter out null values from the properties
  virtual_network_gateway_properties_filtered = {
    for k, v in local.virtual_network_gateway_properties : k => v if v != null
  }
}

locals {
  resource_group_name  = provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.parent_id).resource_group_name
  virtual_network_name = var.subnet_creation_enabled ? basename(var.virtual_network_id) : ""
}

locals {
  default_ip_configuration = {
    name                          = null
    apipa_addresses               = null
    private_ip_address_allocation = "Dynamic"
    public_ip = {
      creation_enabled        = true
      resource_group_name     = null
      id                      = null
      name                    = null
      allocation_method       = "Static"
      sku                     = "Standard"
      tags                    = null
      zones                   = [1, 2, 3]
      edge_zone               = null
      ddos_protection_mode    = "VirtualNetworkInherited"
      ddos_protection_plan_id = null
      domain_name_label       = null
      idle_timeout_in_minutes = null
      ip_tags                 = {}
      ip_version              = "IPv4"
      public_ip_prefix_id     = null
      reverse_fqdn            = null
      sku_tier                = "Regional"
    }
  }
  ip_configurations = {
    for ip_configuration_key, ip_configuration in(
      length(var.ip_configurations) == 0 ? (
        var.vpn_active_active_enabled && var.type == "Vpn" ?
        {
          "001" = local.default_ip_configuration
          "002" = local.default_ip_configuration
        }
        :
        {
          "001" = local.default_ip_configuration
        }
      )
      :
      var.ip_configurations
    )
    : ip_configuration_key => merge(
      ip_configuration,
      {
        name = coalesce(ip_configuration.name, "vnetGatewayConfig${ip_configuration_key}")
        public_ip = merge(
          ip_configuration.public_ip,
          {
            name = coalesce(ip_configuration.public_ip.name, "pip-${var.name}-${ip_configuration_key}")
          }
        )
      }
    )
  }
}

locals {
  express_route_circuit_virtual_network_gateway_connections = {
    for express_route_circuit_key, express_route_circuit in var.express_route_circuits : "erc-${express_route_circuit_key}" => merge(
      express_route_circuit.connection,
      {
        type                     = "ExpressRoute"
        express_route_circuit_id = express_route_circuit.id
      }
    )
    if express_route_circuit.connection != null
  }
  local_network_gateway_virtual_network_gateway_connections = {
    for local_network_gateway_key, local_network_gateway in var.local_network_gateways : "lgw-${local_network_gateway_key}" => merge(
      local_network_gateway.connection,
      {
        local_network_gateway_id = local_network_gateway.id
      }
    )
    if local_network_gateway.connection != null
  }
}

locals {
  express_route_circuit_peerings = {
    for express_route_circuit_key, express_route_circuit in var.express_route_circuits : express_route_circuit_key => merge(
      express_route_circuit.peering,
      {
        express_route_circuit_name = basename(express_route_circuit.id)
      }
    )
    if express_route_circuit.peering != null
  }
}
