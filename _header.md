# Azure Landing Zones Platform Landing Zone Connectivity with Hub and Spoke Virtual Network

This module deploys a hub and spoke virtual network topology aligned to the Azure Landing Zones (ALZ) and Microsoft Cloud Adoption Framework (CAF) for Azure. The module is designed to be used in conjunction with the [Azure Verified Modules](https://aka.ms/AVM) initiative and is part of the [Microsoft Cloud Adoption Framework Azure Landing Zones](https://aka.ms/alz).

This module is leveraged by the [Azure Landing Zones IaC Accelerator](https://aka.ms/alz), head over there to learn more. It is part of the Azure Verified Modules for Platform Landing Zone (ALZ) set of modules.

## Gateway Shared Keys

Continue supplying `shared_key` in the existing gateway connection and ExpressRoute peering objects, including sensitive values such as `random_password.vpn.result`. No separate secret input or state migration is required. Hub keys, connection keys, and resource enablement must be public and known during planning; the shared key itself may remain unknown.

A caller that serializes its entire configuration with an unknown secret can lose that known structure before the module receives it. Such callers must isolate the secret before serialization, as the [full multi-region example](examples/full-multi-region) does internally. Updating this module alone cannot restore an already unknown input. Sensitive business data that is returned by an existing public configuration output must not be declassified to bypass Terraform's output protection.

> **Deprecation notice:** The `id` attribute on entries of the curated `virtual_networks` output (exposed by the `hub-virtual-network-mesh` submodule and consumed internally by this root module) is deprecated in favour of `resource_id` and will be removed in a future major version. New code should read `module.<name>.virtual_networks[<key>].resource_id` or use the top-level `resource_id` map output.
