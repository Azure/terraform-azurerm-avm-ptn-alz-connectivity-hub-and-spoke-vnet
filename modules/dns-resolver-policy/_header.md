# DNS Resolver Policy submodule

This submodule deploys an Azure DNS Security Policy (`Microsoft.Network/dnsResolverPolicies`) and its child resources:

- `Microsoft.Network/dnsResolverPolicies` (the policy itself — single instance per module call)
- `Microsoft.Network/dnsResolverDomainLists` (zero or more sibling domain lists at the same scope)
- `Microsoft.Network/dnsResolverPolicies/dnsSecurityRules` (zero or more security rules under the policy)
- `Microsoft.Network/dnsResolverPolicies/virtualNetworkLinks` (zero or more virtual network links under the policy)

It follows the AVM AzAPI composition guardrails: a single required `parent_id` for the resource group scope (validated via `provider::azapi::parse_resource_id`), the primary resource is named `azapi_resource.this`, `resource_types` is a single object variable, and `retry` / `timeouts` are exposed and applied to every AzAPI resource.
