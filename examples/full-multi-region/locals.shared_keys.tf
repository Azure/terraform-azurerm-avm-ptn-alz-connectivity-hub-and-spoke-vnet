locals {
  shared_key_schema = {
    express_route = {
      express_route_circuits = ["connection", "peering"]
      local_network_gateways = ["connection"]
    }
    vpn = {
      local_network_gateways = ["connection"]
    }
  }
  shared_key_paths = [for descriptor in flatten([
    for hub_key in nonsensitive(try(keys(var.hub_virtual_networks), [])) : [
      for gateway_kind, collections in local.shared_key_schema : [
        for collection_name, blocks in collections : [
          for entry_key in nonsensitive(try(keys(var.hub_virtual_networks[hub_key].virtual_network_gateways[gateway_kind][collection_name]), [])) : [
            for block_name in blocks : { path = [hub_key, gateway_kind, collection_name, entry_key, block_name] }
            if contains(nonsensitive(try(keys(var.hub_virtual_networks[hub_key].virtual_network_gateways[gateway_kind][collection_name][entry_key][block_name]), [])), "shared_key")
          ]
        ]
      ]
    ]
  ]) : descriptor.path]
  shared_key_templates = {
    for path in local.shared_key_paths : base64encode(jsonencode(path)) => replace(replace(jsonencode(sensitive(var.hub_virtual_networks[path[0]].virtual_network_gateways[path[1]][path[2]][path[3]][path[4]].shared_key)), "\"true\"", "{{string_true}}"), "\"false\"", "{{string_false}}")
  }
  rendered_shared_keys = {
    for path_key, template in local.shared_key_templates : path_key => templatestring(template, module.config.custom_replacements)
  }
  shared_key_values = {
    for path_key, rendered in local.rendered_shared_keys : path_key => sensitive(jsondecode(replace(replace(replace(replace(rendered, "\"true\"", "true"), "\"false\"", "false"), "{{string_true}}", "\"true\""), "{{string_false}}", "\"false\"")))
  }
}

locals {
  hub_virtual_networks_template = nonsensitive(var.hub_virtual_networks == null) ? null : {
    for hub_key, hub in var.hub_virtual_networks : hub_key => nonsensitive(hub == null) ? null : merge(
      { for attribute, value in hub : attribute => value if attribute != "virtual_network_gateways" },
      { for attribute, gateways in hub : attribute => nonsensitive(gateways == null) ? null : merge(
        { for gateway_kind, gateway in gateways : gateway_kind => gateway if !contains(keys(local.shared_key_schema), gateway_kind) },
        { for gateway_kind, gateway in gateways : gateway_kind => nonsensitive(gateway == null) ? null : merge(
          { for collection_name, collection in gateway : collection_name => collection if !contains(keys(local.shared_key_schema[gateway_kind]), collection_name) },
          { for collection_name, collection in gateway : collection_name => nonsensitive(collection == null) ? null : {
            for entry_key, entry in collection : entry_key => nonsensitive(entry == null) ? null : merge(
              { for block_name, block in entry : block_name => block if !contains(local.shared_key_schema[gateway_kind][collection_name], block_name) },
              { for block_name, block in entry : block_name => nonsensitive(block == null) ? null : merge(
                { for field_name, field_value in block : field_name => field_value if field_name != "shared_key" },
                { for field_name in nonsensitive(keys(block)) : field_name => base64encode(jsonencode([hub_key, gateway_kind, collection_name, entry_key, block_name])) if field_name == "shared_key" }
              ) if contains(local.shared_key_schema[gateway_kind][collection_name], block_name) }
            )
          } if contains(keys(local.shared_key_schema[gateway_kind]), collection_name) }
        ) if contains(keys(local.shared_key_schema), gateway_kind) }
      ) if attribute == "virtual_network_gateways" }
    )
  }
}

locals {
  templated_hub_virtual_networks = nonsensitive(module.config.outputs.hub_virtual_networks == null) ? null : {
    for hub_key, hub in module.config.outputs.hub_virtual_networks : hub_key => nonsensitive(hub == null) ? null : merge(
      { for attribute, value in hub : attribute => value if attribute != "virtual_network_gateways" },
      { for attribute, gateways in hub : attribute => nonsensitive(gateways == null) ? null : merge(
        { for gateway_kind, gateway in gateways : gateway_kind => gateway if !contains(keys(local.shared_key_schema), gateway_kind) },
        { for gateway_kind, gateway in gateways : gateway_kind => nonsensitive(gateway == null) ? null : merge(
          { for collection_name, collection in gateway : collection_name => collection if !contains(keys(local.shared_key_schema[gateway_kind]), collection_name) },
          { for collection_name, collection in gateway : collection_name => nonsensitive(collection == null) ? null : {
            for entry_key, entry in collection : entry_key => nonsensitive(entry == null) ? null : merge(
              { for block_name, block in entry : block_name => block if !contains(local.shared_key_schema[gateway_kind][collection_name], block_name) },
              { for block_name, block in entry : block_name => nonsensitive(block == null) ? null : merge(
                { for field_name, field_value in block : field_name => field_value if field_name != "shared_key" },
                { for field_name, field_value in block : field_name => try(local.shared_key_values[field_value], sensitive(field_value)) if field_name == "shared_key" }
              ) if contains(local.shared_key_schema[gateway_kind][collection_name], block_name) }
            )
          } if contains(keys(local.shared_key_schema[gateway_kind]), collection_name) }
        ) if contains(keys(local.shared_key_schema), gateway_kind) }
      ) if attribute == "virtual_network_gateways" }
    )
  }
  templated_config = merge(module.config.outputs, {
    hub_virtual_networks = local.templated_hub_virtual_networks
  })
}
