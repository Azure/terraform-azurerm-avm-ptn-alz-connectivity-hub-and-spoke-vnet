module "hub_and_spoke_vnet" {
  source = "./modules/hub-virtual-network-mesh"

  enable_telemetry     = var.enable_telemetry
  hub_virtual_networks = local.hub_virtual_networks
  tags                 = var.tags
}

module "virtual_network_gateway" {
  source   = "./modules/virtual-network-gateway"
  for_each = local.virtual_network_gateways

  location                                  = each.value.virtual_network_gateway.location
  name                                      = each.value.virtual_network_gateway.name
  parent_id                                 = each.value.parent_id
  edge_zone                                 = try(each.value.virtual_network_gateway.edge_zone, null)
  enable_telemetry                          = var.enable_telemetry
  express_route_circuits                    = try(each.value.virtual_network_gateway.express_route_circuits, null)
  express_route_remote_vnet_traffic_enabled = try(each.value.virtual_network_gateway.express_route_remote_vnet_traffic_enabled, false)
  hosted_on_behalf_of_public_ip_enabled     = each.value.virtual_network_gateway.hosted_on_behalf_of_public_ip_enabled
  ip_configurations                         = try(each.value.virtual_network_gateway.ip_configurations, null)
  local_network_gateways                    = try(each.value.virtual_network_gateway.local_network_gateways, null)
  route_table_creation_enabled              = false
  sku                                       = each.value.virtual_network_gateway.sku
  subnet_creation_enabled                   = false
  tags                                      = each.value.tags
  type                                      = each.value.virtual_network_gateway.type
  virtual_network_gateway_subnet_id         = each.value.virtual_network_gateway_subnet_id
  vpn_active_active_enabled                 = try(each.value.virtual_network_gateway.vpn_active_active_enabled, null)
  vpn_bgp_enabled                           = try(each.value.virtual_network_gateway.vpn_bgp_enabled, null)
  vpn_bgp_route_translation_for_nat_enabled = try(each.value.virtual_network_gateway.vpn_bgp_route_translation_for_nat_enabled, false)
  vpn_bgp_settings                          = try(each.value.virtual_network_gateway.vpn_bgp_settings, null)
  vpn_custom_route                          = try(each.value.virtual_network_gateway.vpn_custom_route, null)
  vpn_default_local_network_gateway_id      = try(each.value.virtual_network_gateway.vpn_default_local_network_gateway_id, null)
  vpn_dns_forwarding_enabled                = try(each.value.virtual_network_gateway.vpn_dns_forwarding_enabled, null)
  vpn_generation                            = try(each.value.virtual_network_gateway.vpn_generation, null)
  vpn_ip_sec_replay_protection_enabled      = try(each.value.virtual_network_gateway.vpn_ip_sec_replay_protection_enabled, true)
  vpn_point_to_site                         = try(each.value.virtual_network_gateway.vpn_point_to_site, null)
  vpn_policy_groups                         = try(each.value.virtual_network_gateway.vpn_policy_groups, null)
  vpn_private_ip_address_enabled            = try(each.value.virtual_network_gateway.vpn_private_ip_address_enabled, null)
  vpn_type                                  = try(each.value.virtual_network_gateway.vpn_type, null)

  depends_on = [
    module.hub_and_spoke_vnet
  ]
}

module "gateway_route_table" {
  source   = "Azure/avm-res-network-routetable/azurerm"
  version  = "0.3.1"
  for_each = local.gateway_route_table

  location                      = each.value.location
  name                          = each.value.name
  resource_group_name           = each.value.resource_group_name
  bgp_route_propagation_enabled = each.value.bgp_route_propagation_enabled
  enable_telemetry              = var.enable_telemetry
  tags                          = var.tags
}

module "dns_resolver" {
  source   = "Azure/avm-res-network-dnsresolver/azurerm"
  version  = "0.7.3"
  for_each = local.private_dns_resolver

  location                    = each.value.location
  name                        = each.value.name
  resource_group_name         = each.value.resource_group_name
  virtual_network_resource_id = module.hub_and_spoke_vnet.virtual_networks[each.key].id
  enable_telemetry            = var.enable_telemetry
  inbound_endpoints           = each.value.inbound_endpoints
  outbound_endpoints          = each.value.outbound_endpoints
  tags                        = each.value.tags
}

module "private_dns_zones" {
  source   = "Azure/avm-ptn-network-private-link-private-dns-zones/azurerm"
  version  = "0.15.0"
  for_each = local.private_dns_zones

  location                                    = each.value.location
  resource_group_name                         = each.value.resource_group_name
  enable_telemetry                            = var.enable_telemetry
  private_link_excluded_zones                 = each.value.private_dns_settings.private_link_excluded_zones
  private_link_private_dns_zones              = each.value.private_dns_settings.private_link_private_dns_zones
  private_link_private_dns_zones_additional   = each.value.private_dns_settings.private_link_private_dns_zones_additional
  private_link_private_dns_zones_regex_filter = each.value.private_dns_settings.private_link_private_dns_zones_regex_filter
  resource_group_creation_enabled             = false
  tags                                        = var.tags
  virtual_network_resource_ids_to_link_to     = local.private_dns_zones_virtual_network_links
}

module "private_dns_zone_auto_registration" {
  source   = "Azure/avm-res-network-privatednszone/azurerm"
  version  = "0.3.3"
  for_each = local.private_dns_zones_auto_registration

  domain_name           = each.value.domain_name
  resource_group_name   = each.value.resource_group_name
  enable_telemetry      = var.enable_telemetry
  tags                  = var.tags
  virtual_network_links = each.value.virtual_network_links
}

module "ddos_protection_plan" {
  source  = "Azure/avm-res-network-ddosprotectionplan/azurerm"
  version = "0.3.0"
  count   = local.ddos_protection_plan_enabled ? 1 : 0

  location            = local.ddos_protection_plan.location
  name                = local.ddos_protection_plan.name
  resource_group_name = local.ddos_protection_plan.resource_group_name
  enable_telemetry    = var.enable_telemetry
  tags                = local.ddos_protection_plan_tags
}

module "bastion_public_ip" {
  source   = "Azure/avm-res-network-publicipaddress/azurerm"
  version  = "0.2.0"
  for_each = local.bastion_host_public_ips

  location                = each.value.location
  name                    = each.value.public_ip_settings.name
  resource_group_name     = each.value.resource_group_name
  allocation_method       = each.value.public_ip_settings.allocation_method
  ddos_protection_mode    = each.value.public_ip_settings.ddos_protection_mode
  ddos_protection_plan_id = each.value.public_ip_settings.ddos_protection_plan_id
  domain_name_label       = each.value.public_ip_settings.domain_name_label
  edge_zone               = each.value.public_ip_settings.edge_zone
  enable_telemetry        = var.enable_telemetry
  idle_timeout_in_minutes = each.value.public_ip_settings.idle_timeout_in_minutes
  ip_tags                 = each.value.public_ip_settings.ip_tags
  ip_version              = each.value.public_ip_settings.ip_version
  public_ip_prefix_id     = each.value.public_ip_settings.public_ip_prefix_id
  reverse_fqdn            = each.value.public_ip_settings.reverse_fqdn
  sku                     = each.value.public_ip_settings.sku
  sku_tier                = each.value.public_ip_settings.sku_tier
  tags                    = each.value.tags
  zones                   = each.value.public_ip_settings.zones
}

module "bastion_host" {
  source   = "Azure/avm-res-network-bastionhost/azurerm"
  version  = "0.6.0"
  for_each = local.bastion_hosts

  location               = each.value.location
  name                   = each.value.bastion_settings.name
  resource_group_name    = each.value.resource_group_name
  copy_paste_enabled     = each.value.bastion_settings.copy_paste_enabled
  enable_telemetry       = var.enable_telemetry
  file_copy_enabled      = each.value.bastion_settings.file_copy_enabled
  ip_configuration       = each.value.ip_configuration
  ip_connect_enabled     = each.value.bastion_settings.ip_connect_enabled
  kerberos_enabled       = each.value.bastion_settings.kerberos_enabled
  scale_units            = each.value.bastion_settings.scale_units
  shareable_link_enabled = each.value.bastion_settings.shareable_link_enabled
  sku                    = each.value.bastion_settings.sku
  tags                   = each.value.tags
  tunneling_enabled      = each.value.bastion_settings.tunneling_enabled
  zones                  = each.value.zones
}
