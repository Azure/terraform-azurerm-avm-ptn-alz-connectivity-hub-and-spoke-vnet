locals {
  # Public IP configuration settings (idle_timeout, sku, zones, etc.) - keys must match public_ips
  nat_gateway_public_ip_configuration = {
    for key, value in var.hub_virtual_networks : key => {
      for ip_config_key, ip_config_value in coalesce(try(value.nat_gateway.ip_configurations, null), {}) : ip_config_key => {
        allocation_method       = ip_config_value.public_ip_configuration.allocation_method
        ddos_protection_mode    = ip_config_value.public_ip_configuration.ddos_protection_mode
        idle_timeout_in_minutes = ip_config_value.public_ip_configuration.idle_timeout_in_minutes
        ip_version              = ip_config_value.public_ip_configuration.ip_version
        sku_tier                = ip_config_value.public_ip_configuration.sku_tier
        sku                     = ip_config_value.public_ip_configuration.sku
        zones                   = ip_config_value.public_ip_configuration.zones
        public_ip_prefix_id     = ip_config_value.public_ip_configuration.public_ip_prefix_id
        domain_name_label       = ip_config_value.public_ip_configuration.domain_name_label
      } if ip_config_value.public_ip_creation_enabled
    } if value.nat_gateway != null
  }
  # Public IP prefix IDs (IPv4) to associate with NAT Gateway
  nat_gateway_public_ip_prefix_ids_ipv4 = {
    for key, value in var.hub_virtual_networks : key => [
      for ip_config_key, ip_config_value in coalesce(try(value.nat_gateway.ip_configurations, null), {}) :
      ip_config_value.public_ip_configuration.public_ip_prefix_id
      if ip_config_value.public_ip_configuration.public_ip_prefix_id != null &&
      ip_config_value.public_ip_configuration.ip_version == "IPv4"
    ] if value.nat_gateway != null
  }
  # Public IP prefix IDs (IPv6) to associate with NAT Gateway
  nat_gateway_public_ip_prefix_ids_ipv6 = {
    for key, value in var.hub_virtual_networks : key => [
      for ip_config_key, ip_config_value in coalesce(try(value.nat_gateway.ip_configurations, null), {}) :
      ip_config_value.public_ip_configuration.public_ip_prefix_id
      if ip_config_value.public_ip_configuration.public_ip_prefix_id != null &&
      ip_config_value.public_ip_configuration.ip_version == "IPv6"
    ] if value.nat_gateway != null
  }
  # Existing public IP resource IDs (IPv4) to associate with NAT Gateway
  nat_gateway_public_ip_resource_ids_ipv4 = {
    for key, value in var.hub_virtual_networks : key => [
      for ip_config_key, ip_config_value in coalesce(try(value.nat_gateway.ip_configurations, null), {}) :
      ip_config_value.public_ip_configuration.public_ip_existing_resource_id
      if !ip_config_value.public_ip_creation_enabled &&
      ip_config_value.public_ip_configuration.public_ip_existing_resource_id != null &&
      ip_config_value.public_ip_configuration.ip_version == "IPv4"
    ] if value.nat_gateway != null
  }
  # Existing public IP resource IDs (IPv6) to associate with NAT Gateway
  nat_gateway_public_ip_resource_ids_ipv6 = {
    for key, value in var.hub_virtual_networks : key => [
      for ip_config_key, ip_config_value in coalesce(try(value.nat_gateway.ip_configurations, null), {}) :
      ip_config_value.public_ip_configuration.public_ip_existing_resource_id
      if !ip_config_value.public_ip_creation_enabled &&
      ip_config_value.public_ip_configuration.public_ip_existing_resource_id != null &&
      ip_config_value.public_ip_configuration.ip_version == "IPv6"
    ] if value.nat_gateway != null
  }
  # Public IPs to create (name details) - keys must match public_ip_configuration
  nat_gateway_public_ips = {
    for key, value in var.hub_virtual_networks : key => {
      for ip_config_key, ip_config_value in coalesce(try(value.nat_gateway.ip_configurations, null), {}) : ip_config_key => {
        name = coalesce(ip_config_value.public_ip_configuration.name, "pip-natgw-hub-${value.location}-${ip_config_key}")
      } if ip_config_value.public_ip_creation_enabled
    } if value.nat_gateway != null
  }
  nat_gateways = { for key, value in var.hub_virtual_networks : key => {
    name                             = coalesce(try(value.nat_gateway.name, null), "natgw-hub-${value.location}")
    location                         = coalesce(try(value.nat_gateway.location, null), value.location)
    parent_id                        = coalesce(try(value.nat_gateway.parent_id, null), value.parent_id)
    sku_name                         = try(value.nat_gateway.sku, "Standard")
    idle_timeout_in_minutes          = try(value.nat_gateway.idle_timeout_in_minutes, 4)
    lock                             = try(value.nat_gateway.lock, null)
    public_ip_configuration          = try(local.nat_gateway_public_ip_configuration[key], {})
    public_ips                       = try(local.nat_gateway_public_ips[key], {})
    public_ip_resource_ids_ipv4      = try(local.nat_gateway_public_ip_resource_ids_ipv4[key], [])
    public_ip_resource_ids_ipv6      = try(local.nat_gateway_public_ip_resource_ids_ipv6[key], [])
    public_ip_prefix_resource_ids    = try(local.nat_gateway_public_ip_prefix_ids_ipv4[key], [])
    public_ip_prefix_v6_resource_ids = try(local.nat_gateway_public_ip_prefix_ids_ipv6[key], [])
    tags                             = coalesce(try(value.nat_gateway.tags, null), var.tags, {})
    zones                            = try(value.nat_gateway.zones, null)
  } if value.nat_gateway != null }
}
