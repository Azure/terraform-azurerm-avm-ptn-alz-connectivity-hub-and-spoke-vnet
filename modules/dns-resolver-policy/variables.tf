variable "location" {
  type        = string
  description = "The Azure region where the DNS resolver policy and its child resources will be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the DNS resolver policy (`Microsoft.Network/dnsResolverPolicies`)."
  nullable    = false
}

variable "parent_id" {
  type        = string
  description = "The resource ID of the resource group in which to create the DNS resolver policy, its security rules, virtual network links, and any sibling DNS resolver domain lists."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.parent_id))
    error_message = "parent_id must be a valid resource group resource ID (e.g. /subscriptions/<sub>/resourceGroups/<rg>)."
  }
}

variable "domain_lists" {
  type = map(object({
    name    = optional(string)
    domains = list(string)
    tags    = optional(map(string), null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of `Microsoft.Network/dnsResolverDomainLists` resources to create alongside the policy. Each entry has:

- `name` - (Optional) The name of the domain list. Defaults to the map key.
- `domains` - (Required) The list of domains (FQDNs) in the domain list.
- `tags` - (Optional) A map of tags to apply to the domain list. When `null` the module's `tags` variable is used.
DESCRIPTION
  nullable    = false
}

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

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for the DNS resolver policy.

- `kind` - (Required) The type of lock. Possible values are `CanNotDelete` and `ReadOnly`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value.
DESCRIPTION

  validation {
    condition     = var.lock == null ? true : contains(["CanNotDelete", "ReadOnly"], var.lock.kind)
    error_message = "lock.kind must be either CanNotDelete or ReadOnly."
  }
}

variable "resource_types" {
  type = object({
    dns_resolver_policy                      = optional(string, "Microsoft.Network/dnsResolverPolicies@2023-07-01-preview")
    dns_resolver_domain_list                 = optional(string, "Microsoft.Network/dnsResolverDomainLists@2023-07-01-preview")
    dns_resolver_policy_security_rule        = optional(string, "Microsoft.Network/dnsResolverPolicies/dnsSecurityRules@2023-07-01-preview")
    dns_resolver_policy_virtual_network_link = optional(string, "Microsoft.Network/dnsResolverPolicies/virtualNetworkLinks@2023-07-01-preview")
    lock                                     = optional(string, "Microsoft.Authorization/locks@2020-05-01")
  })
  default     = {}
  description = <<DESCRIPTION
The AzAPI resource type strings (in `<provider>/<type>@<api-version>` form) for every resource deployed by this module. Each key defaults to the tested API version; override individual entries to pin to a different API version.
DESCRIPTION
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string), ["ReferencedResourceNotProvisioned"])
    interval_seconds     = optional(number, 10)
    max_interval_seconds = optional(number, 180)
  })
  default     = {}
  description = <<DESCRIPTION
(Optional) An object defining the retry configuration for resource operations. Applied to every `azapi_resource` in this module.

- `error_message_regex` - (Optional) A list of regular expressions to match against error messages. Default `["ReferencedResourceNotProvisioned"]`.
- `interval_seconds` - (Optional) The initial interval in seconds between retry attempts. Default `10`.
- `max_interval_seconds` - (Optional) The maximum interval in seconds between retry attempts. Default `180`.
DESCRIPTION
  nullable    = false
}

variable "security_rules" {
  type = map(object({
    name                     = optional(string)
    priority                 = number
    action                   = optional(string, "Block")
    state                    = optional(string, "Enabled")
    domain_list_keys         = optional(list(string), [])
    domain_list_resource_ids = optional(list(string), [])
    managed_domain_lists     = optional(list(string), [])
  }))
  default     = {}
  description = <<DESCRIPTION
A map of DNS security rules to create under the policy. Each entry has:

- `name` - (Optional) The name of the rule. Defaults to the map key.
- `priority` - (Required) The priority of the rule. Lower values are evaluated first.
- `action` - (Optional) The action to take when the rule matches. One of `Alert`, `Allow`, `Block`. Default `Block`.
- `state` - (Optional) Whether the rule is `Enabled` or `Disabled`. Default `Enabled`.
- `domain_list_keys` - (Optional) A list of keys referencing entries in `var.domain_lists`. The matching domain list resource IDs are passed to the rule.
- `domain_list_resource_ids` - (Optional) A list of pre-existing domain list resource IDs to associate with the rule.
- `managed_domain_lists` - (Optional) A list of Azure-managed domain lists to associate with the rule. Currently only `AzureDnsThreatIntel` is supported.
DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for _, r in var.security_rules : contains(["Alert", "Allow", "Block"], r.action)])
    error_message = "security_rules[*].action must be one of Alert, Allow, Block."
  }
  validation {
    condition     = alltrue([for _, r in var.security_rules : contains(["Enabled", "Disabled"], r.state)])
    error_message = "security_rules[*].state must be one of Enabled, Disabled."
  }
  validation {
    condition = alltrue([
      for _, r in var.security_rules :
      alltrue([for id in r.domain_list_resource_ids : can(provider::azapi::parse_resource_id("Microsoft.Network/dnsResolverDomainLists", id))])
    ])
    error_message = "security_rules[*].domain_list_resource_ids entries must be valid Microsoft.Network/dnsResolverDomainLists resource IDs."
  }
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Tags to apply to the DNS resolver policy and any child resources that do not override tags themselves."
}

variable "timeouts" {
  type = object({
    create = optional(string, "30m")
    read   = optional(string, "5m")
    update = optional(string, "30m")
    delete = optional(string, "30m")
  })
  default     = {}
  description = <<DESCRIPTION
(Optional) An object defining the timeout durations for AzAPI resource operations. Applied to every `azapi_resource` in this module.

- `create` - (Optional) The timeout for create operations. Default `"30m"`.
- `read` - (Optional) The timeout for read operations. Default `"5m"`.
- `update` - (Optional) The timeout for update operations. Default `"30m"`.
- `delete` - (Optional) The timeout for delete operations. Default `"30m"`.
DESCRIPTION
  nullable    = false
}

variable "virtual_network_links" {
  type = map(object({
    name               = optional(string)
    virtual_network_id = string
  }))
  default     = {}
  description = <<DESCRIPTION
A map of virtual network links (`Microsoft.Network/dnsResolverPolicies/virtualNetworkLinks`) to create under the policy. Each entry has:

- `name` - (Optional) The name of the virtual network link. Defaults to the map key.
- `virtual_network_id` - (Required) The resource ID of the virtual network to link.
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([
      for _, l in var.virtual_network_links : can(provider::azapi::parse_resource_id("Microsoft.Network/virtualNetworks", l.virtual_network_id))
    ])
    error_message = "virtual_network_links[*].virtual_network_id must be a valid Microsoft.Network/virtualNetworks resource ID."
  }
}
