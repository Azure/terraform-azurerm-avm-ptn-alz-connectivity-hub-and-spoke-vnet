module "nat_gateway" {
  source   = "Azure/avm-res-network-natgateway/azurerm"
  version  = "0.3.2"
  for_each = local.nat_gateways

  location                         = each.value.location
  name                             = each.value.name
  parent_id                        = each.value.parent_id
  idle_timeout_in_minutes          = each.value.idle_timeout_in_minutes
  lock                             = each.value.lock
  public_ip_configuration          = each.value.public_ip_configuration
  public_ip_prefix_resource_ids    = each.value.public_ip_prefix_resource_ids
  public_ip_prefix_v6_resource_ids = each.value.public_ip_prefix_v6_resource_ids
  # Existing public IP and prefix resource IDs
  public_ip_resource_ids    = each.value.public_ip_resource_ids_ipv4
  public_ip_v6_resource_ids = each.value.public_ip_resource_ids_ipv6
  # Public IPs to create for this NAT Gateway
  public_ips = each.value.public_ips
  sku_name   = each.value.sku_name
  tags       = each.value.tags
  zones      = each.value.zones
}
