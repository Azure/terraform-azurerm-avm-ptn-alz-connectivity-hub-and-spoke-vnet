# Azure Landing Zones Platform Landing Zone Connectivity with Hub and Spoke Virtual Network

This module deploys a hub and spoke virtual network topology aligned to the Azure Landing Zones (ALZ) and Microsoft Cloud Adoption Framework (CAF) for Azure. The module is designed to be used in conjunction with the [Azure Verified Modules](https://aka.ms/AVM) initiative and is part of the [Microsoft Cloud Adoption Framework Azure Landing Zones](https://aka.ms/alz).

This module is leveraged by the [Azure Landing Zones IaC Accelerator](https://aka.ms/alz), head over there to learn more. It is part of the Azure Verified Modules for Platform Landing Zone (ALZ) set of modules.

## Gateway Shared Keys

Continue supplying `shared_key` in the existing gateway connection and ExpressRoute peering objects, including sensitive values such as `random_password.vpn.result`. No separate secret input or state migration is required. Pass each secret as a sensitive value inside an otherwise non-sensitive configuration. The secret may be unknown during planning, but hub keys, connection keys, and resource enablement must be known.

The module removes sensitive marks only from values that decide which resources and instances exist: map keys, enablement flags, null checks, and private DNS zone selection. Other configuration values and all outputs keep their marks, so an output that carries a sensitive input value is itself sensitive.

A caller that serializes its entire configuration, for example with `jsonencode()`, `templatestring()`, and `jsondecode()`, makes the whole result sensitive when any sensitive value is inside it. Such a caller must isolate every secret before serialization and restore it afterwards, as the [full multi-region example](examples/full-multi-region) does for the four `shared_key` paths. This applies to known and unknown secrets alike:

- With a known secret left inside, the module still plans, but every configuration value returned through its outputs, such as resource names, is sensitive. Root module outputs that re-export these values must be declared with `sensitive = true`.
- With an unknown secret left inside, the whole configuration is unknown, so hub keys and resource enablement are unknown during planning. No change inside this module can recover them.

Isolate any other secret-bearing field that you supply as a sensitive value in the same way, such as `authorization_key`, `vpn_point_to_site.radius_server_secret`, or the `secret` of each `vpn_point_to_site.radius_servers` entry.

> **Deprecation notice:** The `id` attribute on entries of the curated `virtual_networks` output (exposed by the `hub-virtual-network-mesh` submodule and consumed internally by this root module) is deprecated in favour of `resource_id` and will be removed in a future major version. New code should read `module.<name>.virtual_networks[<key>].resource_id` or use the top-level `resource_id` map output.
