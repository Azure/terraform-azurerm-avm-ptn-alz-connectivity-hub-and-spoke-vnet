resource "azapi_resource" "this" {
  location                  = var.location
  name                      = var.name
  parent_id                 = var.parent_id
  type                      = var.resource_types.dns_resolver_policy
  body                      = {}
  create_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers              = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  replace_triggers_refs     = []
  response_export_values    = []
  retry                     = var.retry
  schema_validation_enabled = true
  tags                      = var.tags
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    read   = var.timeouts.read
    update = var.timeouts.update
  }
}

resource "azapi_resource" "domain_list" {
  for_each = var.domain_lists

  location  = var.location
  name      = coalesce(each.value.name, each.key)
  parent_id = var.parent_id
  type      = var.resource_types.dns_resolver_domain_list
  body = {
    properties = {
      domains = each.value.domains
    }
  }
  create_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers              = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  replace_triggers_refs     = []
  response_export_values    = []
  retry                     = var.retry
  schema_validation_enabled = true
  tags                      = coalesce(each.value.tags, var.tags)
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    read   = var.timeouts.read
    update = var.timeouts.update
  }
}

resource "azapi_resource" "security_rule" {
  for_each = var.security_rules

  name      = coalesce(each.value.name, each.key)
  parent_id = azapi_resource.this.id
  type      = var.resource_types.dns_resolver_policy_security_rule
  body = {
    properties = {
      action = {
        actionType = each.value.action
      }
      dnsResolverDomainLists = concat(
        [for k in each.value.domain_list_keys : { id = azapi_resource.domain_list[k].id }],
        [for id in each.value.domain_list_resource_ids : { id = id }],
      )
      dnsSecurityRuleState = each.value.state
      managedDomainLists   = each.value.managed_domain_lists
      priority             = each.value.priority
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  # priority is immutable on this preview API and re-keying replaces the rule, so no body paths need to force replacement.
  replace_triggers_refs  = []
  response_export_values = []
  retry                  = var.retry
  # The bundled azapi 2.x schema for 2023-07-01-preview does not yet recognise the
  # `properties.managedDomainLists` field; ARM still validates the body at apply time.
  schema_validation_enabled = false
  tags                      = var.tags
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    read   = var.timeouts.read
    update = var.timeouts.update
  }
}

resource "azapi_resource" "virtual_network_link" {
  for_each = var.virtual_network_links

  name      = coalesce(each.value.name, each.key)
  parent_id = azapi_resource.this.id
  type      = var.resource_types.dns_resolver_policy_virtual_network_link
  body = {
    properties = {
      virtualNetwork = {
        id = each.value.virtual_network_id
      }
    }
  }
  create_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers              = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  replace_triggers_refs     = ["properties.virtualNetwork.id"]
  response_export_values    = []
  retry                     = var.retry
  schema_validation_enabled = true
  tags                      = var.tags
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    read   = var.timeouts.read
    update = var.timeouts.update
  }
}

resource "azapi_resource" "lock" {
  count = var.lock != null ? 1 : 0

  name      = coalesce(var.lock.name, "lock-${var.lock.kind}")
  parent_id = azapi_resource.this.id
  type      = var.resource_types.lock
  body = {
    properties = {
      level = var.lock.kind
      notes = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
    }
  }
  create_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers              = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  replace_triggers_refs     = ["properties.level"]
  response_export_values    = []
  retry                     = var.retry
  schema_validation_enabled = true
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  timeouts {
    create = var.timeouts.create
    delete = var.timeouts.delete
    read   = var.timeouts.read
    update = var.timeouts.update
  }
}
