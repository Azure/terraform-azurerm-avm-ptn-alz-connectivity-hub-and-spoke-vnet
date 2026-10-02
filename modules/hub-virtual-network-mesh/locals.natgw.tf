locals {
  nat_gateway_ip_configurations = {
    for hub_key, hub in local.hub_virtual_networks_by_key : hub_key => {
      for ip_key in nonsensitive(keys(hub.nat_gateway.ip_configurations)) : ip_key => hub.nat_gateway.ip_configurations[ip_key]
    } if nonsensitive(hub.nat_gateway != null)
  }
  # Public IP configuration settings (idle_timeout, sku, zones, etc.) - keys must match public_ips
  nat_gateway_public_ip_configuration = {
    for key, configurations in local.nat_gateway_ip_configurations : key => {
      for ip_config_key, ip_config_value in configurations : ip_config_key => {
        allocation_method       = ip_config_value.public_ip_configuration.allocation_method
        ddos_protection_mode    = ip_config_value.public_ip_configuration.ddos_protection_mode
        idle_timeout_in_minutes = ip_config_value.public_ip_configuration.idle_timeout_in_minutes
        ip_version              = ip_config_value.public_ip_configuration.ip_version
        sku_tier                = ip_config_value.public_ip_configuration.sku_tier
        sku                     = ip_config_value.public_ip_configuration.sku
        zones                   = ip_config_value.public_ip_configuration.zones
        public_ip_prefix_id     = ip_config_value.public_ip_configuration.public_ip_prefix_id
        domain_name_label       = ip_config_value.public_ip_configuration.domain_name_label
      } if nonsensitive(ip_config_value.public_ip_creation_enabled)
    }
  }
  # Public IP prefix IDs (IPv4) to associate with NAT Gateway
  nat_gateway_public_ip_prefix_ids_ipv4 = {
    for key, configurations in local.nat_gateway_ip_configurations : key => [
      for ip_config_key, ip_config_value in configurations :
      ip_config_value.public_ip_configuration.public_ip_prefix_id
      if ip_config_value.public_ip_configuration.public_ip_prefix_id != null &&
      ip_config_value.public_ip_configuration.ip_version == "IPv4"
    ]
  }
  # Public IP prefix IDs (IPv6) to associate with NAT Gateway
  nat_gateway_public_ip_prefix_ids_ipv6 = {
    for key, configurations in local.nat_gateway_ip_configurations : key => [
      for ip_config_key, ip_config_value in configurations :
      ip_config_value.public_ip_configuration.public_ip_prefix_id
      if ip_config_value.public_ip_configuration.public_ip_prefix_id != null &&
      ip_config_value.public_ip_configuration.ip_version == "IPv6"
    ]
  }
  # Existing public IP resource IDs (IPv4) to associate with NAT Gateway
  nat_gateway_public_ip_resource_ids_ipv4 = {
    for key, configurations in local.nat_gateway_ip_configurations : key => [
      for ip_config_key, ip_config_value in configurations :
      ip_config_value.public_ip_configuration.public_ip_existing_resource_id
      if !ip_config_value.public_ip_creation_enabled &&
      ip_config_value.public_ip_configuration.public_ip_existing_resource_id != null &&
      ip_config_value.public_ip_configuration.ip_version == "IPv4"
    ]
  }
  # Existing public IP resource IDs (IPv6) to associate with NAT Gateway
  nat_gateway_public_ip_resource_ids_ipv6 = {
    for key, configurations in local.nat_gateway_ip_configurations : key => [
      for ip_config_key, ip_config_value in configurations :
      ip_config_value.public_ip_configuration.public_ip_existing_resource_id
      if !ip_config_value.public_ip_creation_enabled &&
      ip_config_value.public_ip_configuration.public_ip_existing_resource_id != null &&
      ip_config_value.public_ip_configuration.ip_version == "IPv6"
    ]
  }
  # Public IPs to create (name details) - keys must match public_ip_configuration
  nat_gateway_public_ips = {
    for key, configurations in local.nat_gateway_ip_configurations : key => {
      for ip_config_key, ip_config_value in configurations : ip_config_key => {
        name = coalesce(ip_config_value.public_ip_configuration.name, "pip-natgw-hub-${local.hub_virtual_networks_by_key[key].location}-${ip_config_key}")
      } if nonsensitive(ip_config_value.public_ip_creation_enabled)
    }
  }
  nat_gateways = { for key, value in local.hub_virtual_networks_by_key : key => {
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
    tags                             = { for tag_key in nonsensitive(keys(coalesce(try(value.nat_gateway.tags, null), var.tags, {}))) : tag_key => coalesce(try(value.nat_gateway.tags, null), var.tags, {})[tag_key] }
    zones                            = try(value.nat_gateway.zones, null)
  } if nonsensitive(value.nat_gateway != null) }
}
