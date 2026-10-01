locals {
  # Per-hub flag indicating whether the DNS resolver policy submodule should be instantiated.
  dns_resolver_policy_enabled = { for key, value in var.hub_virtual_networks :
    key => value.enabled_resources.dns_resolver_policy && value.dns_resolver_policy != null
  }
}

locals {
  # Inputs cascaded into the dns-resolver-policy submodule. Computed once per hub so the
  # module block stays declarative and we don't have to construct the RG resource ID at the
  # call site — callers either let the hub default apply or pass an explicit parent_id.
  dns_resolver_policy = { for key, value in var.hub_virtual_networks : key => {
    name      = coalesce(value.dns_resolver_policy.name, local.default_names[key].dns_resolver_policy_name)
    location  = value.location
    parent_id = coalesce(value.dns_resolver_policy.parent_id, value.default_parent_id, value.hub_virtual_network.parent_id)
    tags      = coalesce(value.dns_resolver_policy.tags, var.tags, {})
    lock      = value.dns_resolver_policy.lock
    domain_lists = {
      for dl_key, dl in value.dns_resolver_policy.domain_lists : dl_key => {
        name    = coalesce(dl.name, local.default_names[key].dns_resolver_domain_list_name)
        domains = dl.domains
        tags    = coalesce(dl.tags, value.dns_resolver_policy.tags, var.tags, {})
      }
    }
    security_rules = value.dns_resolver_policy.rules
    virtual_network_links = merge(
      value.dns_resolver_policy.link_to_hub_virtual_network ? {
        hub = {
          name = templatestring(value.dns_resolver_policy.virtual_network_link_name_template, {
            hub_key   = key
            vnet_name = module.hub_and_spoke_vnet.virtual_networks[key].name
            location  = value.location
          })
          virtual_network_id = module.hub_and_spoke_vnet.resource_id[key]
        }
      } : {},
      value.dns_resolver_policy.additional_virtual_network_links,
    )
    } if local.dns_resolver_policy_enabled[key]
  }
}
