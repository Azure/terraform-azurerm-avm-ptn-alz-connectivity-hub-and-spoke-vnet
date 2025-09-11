module "hub_and_spoke_vnet" {
  source  = "Azure/avm-ptn-hubnetworking/azurerm"
  version = "0.12.3"

  enable_telemetry     = var.enable_telemetry
  hub_virtual_networks = local.hub_virtual_networks
  tags                 = var.tags
}

module "virtual_network_gateway" {
  source   = "Azure/avm-ptn-vnetgateway/azurerm"
  version  = "0.10.2"
  for_each = local.virtual_network_gateways

  location                              = each.value.virtual_network_gateway.location
  name                                  = each.value.virtual_network_gateway.name
  parent_id                             = each.value.virtual_network_gateway.parent_id
  edge_zone                             = try(each.value.virtual_network_gateway.edge_zone, null)
  enable_telemetry                      = var.enable_telemetry
  express_route_circuits                = try(each.value.virtual_network_gateway.express_route_circuits, null)
  hosted_on_behalf_of_public_ip_enabled = try(each.value.virtual_network_gateway.hosted_on_behalf_of_public_ip_enabled, false)
  ip_configurations                     = try(each.value.virtual_network_gateway.ip_configurations, null)
  local_network_gateways                = try(each.value.virtual_network_gateway.local_network_gateways, null)
  route_table_creation_enabled          = false
  sku                                   = each.value.virtual_network_gateway.sku
  subnet_creation_enabled               = false
  tags                                  = var.tags
  type                                  = each.value.virtual_network_gateway.type
  virtual_network_gateway_subnet_id     = each.value.virtual_network_gateway_subnet_id
  vpn_active_active_enabled             = try(each.value.virtual_network_gateway.vpn_active_active_enabled, null)
  vpn_bgp_enabled                       = try(each.value.virtual_network_gateway.vpn_bgp_enabled, null)
  vpn_bgp_settings                      = try(each.value.virtual_network_gateway.vpn_bgp_settings, null)
  vpn_generation                        = try(each.value.virtual_network_gateway.vpn_generation, null)
  vpn_point_to_site                     = try(each.value.virtual_network_gateway.vpn_point_to_site, null)
  vpn_private_ip_address_enabled        = try(each.value.virtual_network_gateway.vpn_private_ip_address_enabled, null)
  vpn_type                              = try(each.value.virtual_network_gateway.vpn_type, null)

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
  outbound_endpoints          = try(each.value.outbound_endpoints, null)
  tags                        = var.tags
}

module "private_dns_zones" {
  source   = "Azure/avm-ptn-network-private-link-private-dns-zones/azurerm"
  version  = "0.15.0"
  for_each = local.private_dns_zones

  location                                    = each.value.location
  resource_group_name                         = each.value.resource_group_name
  enable_telemetry                            = var.enable_telemetry
  private_link_excluded_zones                 = try(each.value.private_link_excluded_zones, [])
  private_link_private_dns_zones              = try(each.value.private_link_private_dns_zones, null)
  private_link_private_dns_zones_additional   = try(each.value.private_link_private_dns_zones_additional, null)
  private_link_private_dns_zones_regex_filter = try(each.value.private_link_private_dns_zones_regex_filter, null)
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
  tags                = var.tags
}

module "bastion_public_ip" {
  source   = "Azure/avm-res-network-publicipaddress/azurerm"
  version  = "0.2.0"
  for_each = local.bastion_host_public_ips

  location                = each.value.location
  name                    = try(each.value.name, "pip-bastion-${each.key}")
  resource_group_name     = each.value.resource_group_name
  allocation_method       = try(each.value.allocation_method, "Static")
  ddos_protection_mode    = try(each.value.ddos_protection_mode, "VirtualNetworkInherited")
  ddos_protection_plan_id = try(each.value.ddos_protection_plan_id, null)
  diagnostic_settings     = try(each.value.diagnostic_settings, null)
  domain_name_label       = try(each.value.domain_name_label, null)
  edge_zone               = try(each.value.edge_zone, null)
  enable_telemetry        = var.enable_telemetry
  idle_timeout_in_minutes = try(each.value.idle_timeout_in_minutes, 4)
  ip_tags                 = try(each.value.ip_tags, null)
  ip_version              = try(each.value.ip_version, "IPv4")
  lock                    = try(each.value.lock, null)
  public_ip_prefix_id     = try(each.value.public_ip_prefix_id, null)
  reverse_fqdn            = try(each.value.reverse_fqdn, null)
  role_assignments        = try(each.value.role_assignments, {})
  sku                     = try(each.value.sku, "Standard")
  sku_tier                = try(each.value.sku_tier, "Regional")
  tags                    = try(each.value.tags, var.tags)
  zones                   = try(each.value.zones, [1, 2, 3])
}

module "bastion_host" {
  source   = "Azure/avm-res-network-bastionhost/azurerm"
  version  = "0.6.0"
  for_each = local.bastion_hosts

  location               = each.value.location
  name                   = try(each.value.name, "snap-bastion-${each.key}")
  resource_group_name    = each.value.resource_group_name
  copy_paste_enabled     = try(each.value.copy_paste_enabled, false)
  diagnostic_settings    = try(each.value.diagnostic_settings, null)
  enable_telemetry       = var.enable_telemetry
  file_copy_enabled      = try(each.value.file_copy_enabled, false)
  ip_configuration       = each.value.ip_configuration
  ip_connect_enabled     = try(each.value.ip_connect_enabled, false)
  kerberos_enabled       = try(each.value.kerberos_enabled, false)
  lock                   = try(each.value.lock, null)
  role_assignments       = try(each.value.role_assignments, {})
  scale_units            = try(each.value.scale_units, 2)
  shareable_link_enabled = try(each.value.shareable_link_enabled, false)
  sku                    = try(each.value.sku, "Standard")
  tags                   = try(each.value.tags, var.tags)
  tunneling_enabled      = try(each.value.tunneling_enabled, false)
  virtual_network_id     = try(each.value.virtual_network_id, null)
  zones                  = try(each.value.zones, try(local.bastion_host_public_ips[each.key].zones, null))
}
