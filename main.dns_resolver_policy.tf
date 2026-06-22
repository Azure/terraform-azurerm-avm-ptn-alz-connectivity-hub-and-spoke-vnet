module "dns_resolver_policy" {
  source   = "./modules/dns-resolver-policy"
  for_each = local.dns_resolver_policy

  location              = each.value.location
  name                  = each.value.name
  parent_id             = each.value.parent_id
  domain_lists          = each.value.domain_lists
  enable_telemetry      = var.enable_telemetry
  lock                  = each.value.lock
  retry                 = var.retry
  security_rules        = each.value.security_rules
  tags                  = each.value.tags
  timeouts              = var.timeouts
  virtual_network_links = each.value.virtual_network_links
}
