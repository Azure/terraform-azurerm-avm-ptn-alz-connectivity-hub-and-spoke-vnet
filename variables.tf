variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "hub_and_spoke_networks_settings" {
  type        = any
  default     = {}
  description = <<DESCRIPTION
The shared settings for the hub and spoke networks. This is where global resources are defined.

The following attributes are supported:

  - ddos_protection_plan: (Optional) The DDoS protection plan settings. Detailed information about the DDoS protection plan can be found in the module's README: <https://registry.terraform.io/modules/Azure/avm-res-network-ddosprotectionplan/azurerm/latest>

DESCRIPTION
}

variable "hub_virtual_networks" {
  type = map(object({
    hub_virtual_network = object({
      name                          = string
      address_space                 = list(string)
      location                      = string
      parent_id                     = string
      route_table_name_firewall     = optional(string)
      route_table_name_user_subnets = optional(string)
      bgp_community                 = optional(string)
      ddos_protection_plan_id       = optional(string)
      dns_servers                   = optional(list(string))
      flow_timeout_in_minutes       = optional(number, 4)
      mesh_peering_enabled          = optional(bool, true)
      peering_names                 = optional(map(string))
      routing_address_space         = optional(list(string), [])
      hub_router_ip_address         = optional(string)
      tags                          = optional(map(string))

      route_table_entries_firewall = optional(set(object({
        name                = string
        address_prefix      = string
        next_hop_type       = string
        has_bgp_override    = optional(bool, false)
        next_hop_ip_address = optional(string)
      })), [])

      route_table_entries_user_subnets = optional(set(object({
        name                = string
        address_prefix      = string
        next_hop_type       = string
        has_bgp_override    = optional(bool, false)
        next_hop_ip_address = optional(string)
      })), [])

      subnets = optional(map(object(
        {
          name             = string
          address_prefixes = list(string)
          nat_gateway = optional(object({
            id = string
          }))
          network_security_group = optional(object({
            id = string
          }))
          private_endpoint_network_policies_enabled     = optional(bool, true)
          private_link_service_network_policies_enabled = optional(bool, true)
          route_table = optional(object({
            id                           = optional(string)
            assign_generated_route_table = optional(bool, true)
          }))
          service_endpoints           = optional(set(string))
          service_endpoint_policy_ids = optional(set(string))
          delegations = optional(list(
            object(
              {
                name = string
                service_delegation = object({
                  name    = string
                  actions = optional(list(string))
                })
              }
            )
          ))
          default_outbound_access_enabled = optional(bool, false)
        }
      )), {})
    })
    firewall = optional(object({
      enabled                                           = optional(bool, false)
      sku_name                                          = string
      sku_tier                                          = string
      subnet_address_prefix                             = string
      subnet_default_outbound_access_enabled            = optional(bool, false)
      firewall_policy_id                                = optional(string, null)
      management_ip_enabled                             = optional(bool, true)
      management_subnet_address_prefix                  = optional(string, null)
      management_subnet_default_outbound_access_enabled = optional(bool, false)
      name                                              = optional(string)
      private_ip_ranges                                 = optional(list(string))
      subnet_route_table_id                             = optional(string)
      tags                                              = optional(map(string))
      zones                                             = optional(list(string))

      default_ip_configuration = optional(object({
        is_default = optional(bool, true)
        name       = optional(string)
        public_ip_config = optional(object({
          ip_version = optional(string, "IPv4")
          name       = optional(string)
          sku_tier   = optional(string, "Regional")
          zones      = optional(set(string))
        }))
      }))
      ip_configurations = optional(map(object({
        is_default = optional(bool, false)
        name       = optional(string)
        public_ip_config = optional(object({
          ip_version = optional(string, "IPv4")
          name       = optional(string)
          sku_tier   = optional(string, "Regional")
          zones      = optional(set(string))
        }))
      })), {})
      management_ip_configuration = optional(object({
        name = optional(string)
        public_ip_config = optional(object({
          ip_version = optional(string, "IPv4")
          name       = optional(string)
          sku_tier   = optional(string, "Regional")
          zones      = optional(set(string))
        }))
      }))
    }))
    firewall_policy = optional(object({
      enabled                           = optional(bool, false)
      name                              = optional(string)
      sku                               = optional(string, "Standard")
      auto_learn_private_ranges_enabled = optional(bool)
      base_policy_id                    = optional(string)
      dns = optional(object({
        proxy_enabled = optional(bool, false)
        servers       = optional(list(string))
      }))
      explicit_proxy = optional(object({
        enable_pac_file = optional(bool)
        enabled         = optional(bool)
        http_port       = optional(number)
        https_port      = optional(number)
        pac_file        = optional(string)
        pac_file_port   = optional(number)
      }))
      identity = optional(object({
        type         = string
        identity_ids = optional(set(string))
      }))
      insights = optional(object({
        default_log_analytics_workspace_id = string
        enabled                            = bool
        retention_in_days                  = optional(number)
        log_analytics_workspace = optional(list(object({
          firewall_location = string
          id                = string
        })))
      }))
      intrusion_detection = optional(object({
        mode           = optional(string)
        private_ranges = optional(list(string))
        signature_overrides = optional(list(object({
          id    = optional(string)
          state = optional(string)
        })))
        traffic_bypass = optional(list(object({
          description           = optional(string)
          destination_addresses = optional(set(string))
          destination_ip_groups = optional(set(string))
          destination_ports     = optional(set(string))
          name                  = string
          protocol              = string
          source_addresses      = optional(set(string))
          source_ip_groups      = optional(set(string))
        })))
      }))
      private_ip_ranges        = optional(list(string))
      sql_redirect_allowed     = optional(bool, false)
      threat_intelligence_mode = optional(string, "Alert")

      threat_intelligence_allowlist = optional(object({
        fqdns        = optional(set(string))
        ip_addresses = optional(set(string))
      }))
      tls_certificate = optional(object({
        key_vault_secret_id = string
        name                = string
      }))
    }))
    bastion = optional(object({
      enabled                                = optional(bool, true)
      subnet_address_prefix                  = string
      subnet_default_outbound_access_enabled = optional(bool, false)
      bastion_host                           = any
      bastion_public_ip                      = any
    }))
    virtual_network_gateways = optional(object({
      subnet_address_prefix                     = string
      subnet_default_outbound_access_enabled    = optional(bool, false)
      route_table_creation_enabled              = optional(bool, false)
      route_table_name                          = optional(string)
      route_table_bgp_route_propagation_enabled = optional(bool, false)
      express_route = optional(object({
        enabled   = optional(bool, true)
        name      = string
        parent_id = optional(string)
        sku       = string
        edge_zone = optional(string)
        express_route_circuits = optional(map(object({
          id = string
          connection = optional(object({
            resource_group_name            = optional(string, null)
            authorization_key              = optional(string, null)
            express_route_gateway_bypass   = optional(bool, null)
            private_link_fast_path_enabled = optional(bool, false)
            name                           = optional(string, null)
            routing_weight                 = optional(number, null)
            shared_key                     = optional(string, null)
            tags                           = optional(map(string), {})
          }), null)
          peering = optional(object({
            peering_type                  = string
            vlan_id                       = number
            resource_group_name           = optional(string, null)
            ipv4_enabled                  = optional(bool, true)
            peer_asn                      = optional(number, null)
            primary_peer_address_prefix   = optional(string, null)
            secondary_peer_address_prefix = optional(string, null)
            shared_key                    = optional(string, null)
            route_filter_id               = optional(string, null)
            microsoft_peering_config = optional(object({
              advertised_public_prefixes = list(string)
              advertised_communities     = optional(list(string), null)
              customer_asn               = optional(number, null)
              routing_registry_name      = optional(string, null)
            }), null)
          }), null)
        })))
        express_route_remote_vnet_traffic_enabled = optional(bool, false)
        hosted_on_behalf_of_public_ip_enabled     = optional(bool, false)
        ip_configurations = optional(map(object({
          name                          = optional(string, null)
          apipa_addresses               = optional(list(string), null)
          private_ip_address_allocation = optional(string, "Dynamic")
          public_ip = optional(object({
            creation_enabled        = optional(bool, true)
            id                      = optional(string, null)
            name                    = optional(string, null)
            resource_group_name     = optional(string, null)
            allocation_method       = optional(string, "Static")
            sku                     = optional(string, "Standard")
            tags                    = optional(map(string), {})
            zones                   = optional(list(number), [1, 2, 3])
            edge_zone               = optional(string, null)
            ddos_protection_mode    = optional(string, "VirtualNetworkInherited")
            ddos_protection_plan_id = optional(string, null)
            domain_name_label       = optional(string, null)
            idle_timeout_in_minutes = optional(number, null)
            ip_tags                 = optional(map(string), {})
            ip_version              = optional(string, "IPv4")
            public_ip_prefix_id     = optional(string, null)
            reverse_fqdn            = optional(string, null)
            sku_tier                = optional(string, "Regional")
          }), {})
        })))
        local_network_gateways = optional(map(object({
          id                  = optional(string, null)
          name                = optional(string, null)
          resource_group_name = optional(string, null)
          address_space       = optional(list(string), null)
          gateway_fqdn        = optional(string, null)
          gateway_address     = optional(string, null)
          tags                = optional(map(string), {})
          bgp_settings = optional(object({
            asn                 = number
            bgp_peering_address = string
            peer_weight         = optional(number, null)
          }), null)
          connection = optional(object({
            name                               = optional(string, null)
            resource_group_name                = optional(string, null)
            type                               = string
            connection_mode                    = optional(string, null)
            connection_protocol                = optional(string, null)
            dpd_timeout_seconds                = optional(number, null)
            egress_nat_rule_ids                = optional(list(string), null)
            enable_bgp                         = optional(bool, null)
            ingress_nat_rule_ids               = optional(list(string), null)
            local_azure_ip_address_enabled     = optional(bool, null)
            peer_virtual_network_gateway_id    = optional(string, null)
            routing_weight                     = optional(number, null)
            shared_key                         = optional(string, null)
            tags                               = optional(map(string), null)
            use_policy_based_traffic_selectors = optional(bool, null)
            custom_bgp_addresses = optional(object({
              primary   = string
              secondary = string
            }), null)
            ipsec_policy = optional(object({
              dh_group         = string
              ike_encryption   = string
              ike_integrity    = string
              ipsec_encryption = string
              ipsec_integrity  = string
              pfs_group        = string
              sa_datasize      = optional(number, null)
              sa_lifetime      = optional(number, null)
            }), null)
            traffic_selector_policy = optional(list(
              object({
                local_address_prefixes  = list(string)
                remote_address_prefixes = list(string)
              })
            ), null)
          }), null)
        })))
        tags = optional(map(string))
      }))
      vpn = optional(object({
        enabled                               = optional(bool, true)
        name                                  = string
        parent_id                             = optional(string)
        sku                                   = string
        edge_zone                             = optional(string)
        hosted_on_behalf_of_public_ip_enabled = optional(bool, false)
        ip_configurations = optional(map(object({
          name                          = optional(string, null)
          apipa_addresses               = optional(list(string), null)
          private_ip_address_allocation = optional(string, "Dynamic")
          public_ip = optional(object({
            creation_enabled        = optional(bool, true)
            id                      = optional(string, null)
            name                    = optional(string, null)
            resource_group_name     = optional(string, null)
            allocation_method       = optional(string, "Static")
            sku                     = optional(string, "Standard")
            tags                    = optional(map(string), {})
            zones                   = optional(list(number), [1, 2, 3])
            edge_zone               = optional(string, null)
            ddos_protection_mode    = optional(string, "VirtualNetworkInherited")
            ddos_protection_plan_id = optional(string, null)
            domain_name_label       = optional(string, null)
            idle_timeout_in_minutes = optional(number, null)
            ip_tags                 = optional(map(string), {})
            ip_version              = optional(string, "IPv4")
            public_ip_prefix_id     = optional(string, null)
            reverse_fqdn            = optional(string, null)
            sku_tier                = optional(string, "Regional")
          }), {})
        })))
        local_network_gateways = optional(map(object({
          id                  = optional(string, null)
          name                = optional(string, null)
          resource_group_name = optional(string, null)
          address_space       = optional(list(string), null)
          gateway_fqdn        = optional(string, null)
          gateway_address     = optional(string, null)
          tags                = optional(map(string), {})
          bgp_settings = optional(object({
            asn                 = number
            bgp_peering_address = string
            peer_weight         = optional(number, null)
          }), null)
          connection = optional(object({
            name                               = optional(string, null)
            resource_group_name                = optional(string, null)
            type                               = string
            connection_mode                    = optional(string, null)
            connection_protocol                = optional(string, null)
            dpd_timeout_seconds                = optional(number, null)
            egress_nat_rule_ids                = optional(list(string), null)
            enable_bgp                         = optional(bool, null)
            ingress_nat_rule_ids               = optional(list(string), null)
            local_azure_ip_address_enabled     = optional(bool, null)
            peer_virtual_network_gateway_id    = optional(string, null)
            routing_weight                     = optional(number, null)
            shared_key                         = optional(string, null)
            tags                               = optional(map(string), null)
            use_policy_based_traffic_selectors = optional(bool, null)
            custom_bgp_addresses = optional(object({
              primary   = string
              secondary = string
            }), null)
            ipsec_policy = optional(object({
              dh_group         = string
              ike_encryption   = string
              ike_integrity    = string
              ipsec_encryption = string
              ipsec_integrity  = string
              pfs_group        = string
              sa_datasize      = optional(number, null)
              sa_lifetime      = optional(number, null)
            }), null)
            traffic_selector_policy = optional(list(
              object({
                local_address_prefixes  = list(string)
                remote_address_prefixes = list(string)
              })
            ), null)
          }), null)
        })))
        tags                                      = optional(map(string))
        vpn_active_active_enabled                 = optional(bool, true)
        vpn_bgp_enabled                           = optional(bool, false)
        vpn_bgp_route_translation_for_nat_enabled = optional(bool, false)
        vpn_bgp_settings = optional(object({
          asn         = optional(number, 65515)
          peer_weight = optional(number, null)
        }))
        vpn_custom_route = optional(object({
          address_prefixes = list(string)
        }))
        vpn_default_local_network_gateway_id = optional(string, null)
        vpn_dns_forwarding_enabled           = optional(bool, false)
        vpn_generation                       = optional(string, null)
        vpn_ip_sec_replay_protection_enabled = optional(bool, true)
        vpn_point_to_site = optional(object({
          address_space         = list(string)
          aad_tenant            = optional(string, null)
          aad_audience          = optional(string, null)
          aad_issuer            = optional(string, null)
          radius_server_address = optional(string, null)
          radius_server_secret  = optional(string, null)
          root_certificates = optional(map(object({
            name             = string
            public_cert_data = string
          })), {})
          revoked_certificates = optional(map(object({
            name       = string
            thumbprint = string
          })), {})
          radius_servers = optional(map(object({
            address = string
            secret  = string
            score   = number
          })), {})
          vpn_client_protocols = optional(list(string), null)
          vpn_auth_types       = optional(list(string), null)
          ipsec_policy = optional(object({
            dh_group                  = string
            ike_encryption            = string
            ike_integrity             = string
            ipsec_encryption          = string
            ipsec_integrity           = string
            pfs_group                 = string
            sa_data_size_in_kilobytes = optional(number, null)
            sa_lifetime_in_seconds    = optional(number, null)
          }), null)
          virtual_network_gateway_client_connections = optional(map(object({
            name               = string
            policy_group_names = list(string)
            address_prefixes   = list(string)
          })), {})
        }))
        vpn_policy_groups = optional(map(object({
          name       = string
          is_default = optional(bool, null)
          priority   = optional(number, null)
          policy_members = map(object({
            name  = string
            type  = string
            value = string
          }))
        })))
        vpn_private_ip_address_enabled = optional(bool, false)
        vpn_type                       = optional(string, null)
      }))
    }))
    private_dns_zones = optional(object({
      enabled                                    = optional(bool, true)
      dns_zones                                  = any
      auto_registration_zone_enabled             = optional(bool, true)
      auto_registration_zone_name                = optional(string, null)
      auto_registration_zone_resource_group_name = optional(string, null)
    }))
    private_dns_resolver = optional(object({
      enabled                                = optional(bool, true)
      subnet_address_prefix                  = string
      subnet_name                            = optional(string, "dns-resolver")
      subnet_default_outbound_access_enabled = optional(bool, false)
      default_inbound_endpoint_enabled       = optional(bool, true)
      name                                   = string
      ip_address                             = optional(string, null)
      inbound_endpoints = optional(map(object({
        name                         = optional(string)
        subnet_name                  = string
        private_ip_allocation_method = optional(string, "Dynamic")
        private_ip_address           = optional(string, null)
        tags                         = optional(map(string), null)
        merge_with_module_tags       = optional(bool, true)
      })), {})
      outbound_endpoints = optional(map(object({
        name                   = optional(string)
        tags                   = optional(map(string), null)
        merge_with_module_tags = optional(bool, true)
        subnet_name            = string
        forwarding_ruleset = optional(map(object({
          name                                                = optional(string)
          link_with_outbound_endpoint_virtual_network         = optional(bool, true)
          metadata_for_outbound_endpoint_virtual_network_link = optional(map(string), null)
          tags                                                = optional(map(string), null)
          merge_with_module_tags                              = optional(bool, true)
          additional_outbound_endpoint_link = optional(object({
            outbound_endpoint_key = optional(string)
          }), null)
          additional_virtual_network_links = optional(map(object({
            name     = optional(string)
            vnet_id  = string
            metadata = optional(map(string), null)
          })), {})
          rules = optional(map(object({
            name                     = optional(string)
            domain_name              = string
            destination_ip_addresses = map(string)
            enabled                  = optional(bool, true)
            metadata                 = optional(map(string), null)
          })))
        })))
      })), {})
      tags = optional(map(string), null)
    }))
  }))
  default     = {}
  description = <<DESCRIPTION
A map of hub networks to create.

The following tope level attributes are supported:

  - hub_virtual_network: The hub virtual network settings.
  - firewall: (Optional) The firewall settings.
  - firewall_policy: (Optional) The firewall policy settings.
  - bastion: (Optional) The bastion host settings.
  - virtual_network_gateways: (Optional) The virtual network gateway settings.
  - private_dns_zones: (Optional) The private DNS zone settings.
  - private_dns_resolver: (Optional) The private DNS resolver settings.

## Hub Virtual Network

### Mandatory fields

- `name` - The name of the Virtual Network.
- `address_space` - A list of IPv4 address spaces that are used by this virtual network in CIDR format, e.g. `["192.168.0.0/24"]`.
- `location` - The Azure location where the virtual network should be created.
- `parent_id` - The ID of the parent resource group where the virtual network should be created.

### Optional fields

- `bgp_community` - The BGP community associated with the virtual network.
- `ddos_protection_plan_id` - The ID of the DDoS protection plan associated with the virtual network.
- `dns_servers` - A list of DNS servers IP addresses for the virtual network.
- `flow_timeout_in_minutes` - The flow timeout in minutes for the virtual network. Default `4`.
- `mesh_peering_enabled` - Should the virtual network be peered to other hub networks with this flag enabled? Default `true`.
- `peering_names` - A map of the names of the peering connections to create between this virtual network and other hub networks. The key is the key of the peered hub network, and the value is the name of the peering connection.
- `route_table_name_firewall` - The name of the route table to create for the firewall routes. Default `route-{vnetname}`.
- `route_table_name_user_subnets` - The name of the route table to create for the user subnet routes. Default `route-{vnetname}`.
- `routing_address_space` - A list of IPv4 address spaces in CIDR format that are used for routing to this hub, e.g. `["192.168.0.0","172.16.0.0/12"]`.
- `hub_router_ip_address` - If not using Azure Firewall, this is the IP address of the hub router. This is used to create route table entries for other hub networks.
- `tags` - A map of tags to apply to the virtual network.

#### Route table entries

- `route_table_entries_firewall` - (Optional) A set of additional route table entries to add to the Firewall route table for this hub network. Default empty `[]`. The value is an object with the following fields:
  - `name` - The name of the route table entry.
  - `address_prefix` - The address prefix to match for this route table entry.
  - `next_hop_type` - The type of the next hop. Possible values include `Internet`, `VirtualAppliance`, `VirtualNetworkGateway`, `VnetLocal`, `None`.
  - `has_bgp_override` - Should the BGP override be enabled for this route table entry? Default `false`.
  - `next_hop_ip_address` - The IP address of the next hop. Required if `next_hop_type` is `VirtualAppliance`.

- `route_table_entries_user_subnets` - (Optional) A set of additional route table entries to add to the User Subnets route table for this hub network. Default empty `[]`. The value is an object with the following fields:
  - `name` - The name of the route table entry.
  - `address_prefix` - The address prefix to match for this route table entry.
  - `next_hop_type` - The type of the next hop. Possible values include `Internet`, `VirtualAppliance`, `VirtualNetworkGateway`, `VnetLocal`, `None`.
  - `has_bgp_override` - Should the BGP override be enabled for this route table entry? Default `false`.
  - `next_hop_ip_address` - The IP address of the next hop. Required if `next_hop_type` is `VirtualAppliance`.

#### Subnets

- `subnets` - (Optional) A map of subnets to create in the virtual network. The value is an object with the following fields:
  - `name` - The name of the subnet.
  - `address_prefixes` - The IPv4 address prefixes to use for the subnet in CIDR format.
  - `nat_gateway` - (Optional) An object with the following fields:
    - `id` - The ID of the NAT Gateway which should be associated with the Subnet. Changing this forces a new resource to be created.
  - `network_security_group` - (Optional) An object with the following fields:
    - `id` - The ID of the Network Security Group which should be associated with the Subnet. Changing this forces a new association to be created.
  - `private_endpoint_network_policies_enabled` - (Optional) Enable or Disable network policies for the private endpoint on the subnet. Setting this to true will Enable the policy and setting this to false will Disable the policy. Defaults to true.
  - `private_link_service_network_policies_enabled` - (Optional) Enable or Disable network policies for the private link service on the subnet. Setting this to true will Enable the policy and setting this to false will Disable the policy. Defaults to true.
  - `route_table` - (Optional) An object with the following fields which are mutually exclusive, choose either an external route table or the generated route table:
    - `id` - The ID of the Route Table which should be associated with the Subnet. Changing this forces a new association to be created.
    - `assign_generated_route_table` - (Optional) Should the Route Table generated by this module be associated with this Subnet? Default `true`.
  - `service_endpoints` - (Optional) The list of Service endpoints to associate with the subnet.
  - `service_endpoint_policy_ids` - (Optional) The list of Service Endpoint Policy IDs to associate with the subnet.
  - `service_endpoint_policy_assignment_enabled` - (Optional) Should the Service Endpoint Policy be assigned to the subnet? Default `true`.
  - `delegation` - (Optional) An object with the following fields:
    - `name` - The name of the delegation.
    - `service_delegation` - An object with the following fields:
      - `name` - The name of the service delegation.
      - `actions` - A list of actions that should be delegated, the list is specific to the service being delegated.
  - `default_outbound_access_enabled` - (Optional) Should the default outbound access be enabled for the subnet? Default `false`.

## Azure Firewall

- `firewall` - (Optional) An object with the following fields:
  - `sku_name` - The name of the SKU to use for the Azure Firewall. Possible values include `AZFW_Hub`, `AZFW_VNet`.
  - `sku_tier` - The tier of the SKU to use for the Azure Firewall. Possible values include `Basic`, ``Standard`, `Premium`.
  - `subnet_address_prefix` - The IPv4 address prefix to use for the Azure Firewall subnet in CIDR format. Needs to be a part of the virtual network's address space.
  - `subnet_default_outbound_access_enabled` - (Optional) Should the default outbound access be enabled for the Azure Firewall subnet? Default `false`.
  - `firewall_policy_id` - (Optional) The resource id of the Azure Firewall Policy to associate with the Azure Firewall.
  - `management_ip_enabled` - (Optional) Should the Azure Firewall management IP be enabled? Default `true`.
  - `management_subnet_address_prefix` - (Optional) The IPv4 address prefix to use for the Azure Firewall management subnet in CIDR format. Needs to be a part of the virtual network's address space.
  - `management_subnet_default_outbound_access_enabled` - (Optional) Should the default outbound access be enabled for the Azure Firewall management subnet? Default `false`.
  - `name` - (Optional) The name of the firewall resource. If not specified will use `afw-{vnetname}`.
  - `private_ip_ranges` - (Optional) A list of private IP ranges to use for the Azure Firewall, to which the firewall will not NAT traffic. If not specified will use RFC1918.
  - `subnet_route_table_id` = (Optional) The resource id of the Route Table which should be associated with the Azure Firewall subnet. If not specified the module will assign the generated route table.
  - `tags` - (Optional) A map of tags to apply to the Azure Firewall. If not specified
  - `zones` - (Optional) A list of availability zones to use for the Azure Firewall. If not specified will be `null`.
  - `default_ip_configuration` - (Optional) An object with the following fields. This is for legacy purpose, consider using `ip_configurations` instead. If `ip_configurations` is specified, this input will be ignored. If not specified the defaults below will be used:
    - `name` - (Optional) The name of the default IP configuration. If not specified will use `default`.
    - `is_default` - (Optional) Indicates this is the default IP configuration. This must always be `true` for the legacy configuration. If not specified will be `true`.
    - `public_ip_config` - (Optional) An object with the following fields:
      - `name` - (Optional) The name of the public IP configuration. If not specified will use `pip-fw-{vnetname}`.
      - `zones` - (Optional) A list of availability zones to use for the public IP configuration. If not specified will be `null`.
      - `ip_version` - (Optional) The IP version to use for the public IP configuration. Possible values include `IPv4`, `IPv6`. If not specified will be `IPv4`.
      - `sku_tier` - (Optional) The SKU tier to use for the public IP configuration. Possible values include `Regional`, `Global`. If not specified will be `Regional`.
  - `ip_configurations` - (Optional) A map of the default IP configuration for the Azure Firewall. If not specified the defaults below will be used:
    - `name` - (Optional) The name of the default IP configuration. If not specified will use `default`.
    - `is_default` - (Optional) Indicates this is the default IP configuration, which will be linked to the Firewall subnet. If not specified will be `false`. At least one and only one IP configuration must have this set to `true`.
    - `public_ip_config` - (Optional) An object with the following fields:
      - `name` - (Optional) The name of the public IP configuration. If not specified will use `pip-fw-{vnetname}-<Map Key>`.
      - `zones` - (Optional) A list of availability zones to use for the public IP configuration. If not specified will be `null`.
      - `ip_version` - (Optional) The IP version to use for the public IP configuration. Possible values include `IPv4`, `IPv6`. If not specified will be `IPv4`.
      - `sku_tier` - (Optional) The SKU tier to use for the public IP configuration. Possible values include `Regional`, `Global`. If not specified will be `Regional`.
  - `management_ip_configuration` - (Optional) An object with the following fields. If not specified the defaults below will be used:
    - `name` - (Optional) The name of the management IP configuration. If not specified will use `defaultMgmt`.
    - `public_ip_config` - (Optional) An object with the following fields:
      - `name` - (Optional) The name of the public IP configuration. If not specified will use `pip-fw-mgmt-<Map Key>`.
      - `zones` - (Optional) A list of availability zones to use for the public IP configuration. If not specified will be `null`.
      - `ip_version` - (Optional) The IP version to use for the public IP configuration. Possible values include `IPv4`, `IPv6`. If not specified will be `IPv4`.
      - `sku_tier` - (Optional) The SKU tier to use for the public IP configuration. Possible values include `Regional`, `Global`. If not specified will be `Regional`.

## Azure Firewall Policy

- `firewall_policy` - (Optional) An object with the following fields. Cannot be used with `firewall_policy_id`. If not specified the defaults below will be used:
  - `name` - (Optional) The name of the firewall policy. If not specified will use `afw-policy-{vnetname}`.
  - `sku` - (Optional) The SKU to use for the firewall policy. Possible values include `Standard`, `Premium`.
  - `auto_learn_private_ranges_enabled` - (Optional) Should the firewall policy automatically learn private ranges? Default `false`.
  - `base_policy_id` - (Optional) The resource id of the base policy to use for the firewall policy.
  - `dns` - (Optional) An object with the following fields:
    - `proxy_enabled` - (Optional) Should the DNS proxy be enabled for the firewall policy? Default `false`.
    - `servers` - (Optional) A list of DNS server IP addresses for the firewall policy.
  - `threat_intelligence_mode` - (Optional) The threat intelligence mode for the firewall policy. Possible values include `Alert`, `Deny`, `Off`.
  - `private_ip_ranges` - (Optional) A list of private IP ranges to use for the firewall policy.
  - `threat_intelligence_allowlist` - (Optional) An object with the following fields:
    - `fqdns` - (Optional) A set of FQDNs to allowlist for threat intelligence.
    - `ip_addresses` - (Optional) A set of IP addresses to allowlist for threat intelligence.

DESCRIPTION
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}
