# Azure Landing Zones Platform Landing Zone Connectivity with Hub and Spoke Virtual Network

This module deploys a hub and spoke virtual network topology aligned to the Azure Landing Zones (ALZ) and Microsoft Cloud Adoption Framework (CAF) for Azure. The module is designed to be used in conjunction with the [Azure Verified Modules](https://aka.ms/AVM) initiative and is part of the [Microsoft Cloud Adoption Framework Azure Landing Zones](https://aka.ms/alz).

This module is leveraged by the [Azure Landing Zones IaC Accelerator](https://aka.ms/alz), head over there to learn more. It is part of the Azure Verified Modules for Platform Landing Zone (ALZ) set of modules.

> **Deprecation notice:** The `id` attribute on entries of the curated `virtual_networks` output (exposed by the `hub-virtual-network-mesh` submodule and consumed internally by this root module) is deprecated in favour of `resource_id` and will be removed in a future major version. New code should read `module.<name>.virtual_networks[<key>].resource_id` or use the top-level `resource_id` map output.

## Configuring subnet Service Endpoints

Configure subnet Service Endpoints with the names-only `service_endpoints` set of service names. This is the only supported form:

```terraform
subnets = {
  workload = {
    name              = "workload"
    address_prefixes  = ["192.168.1.0/24"]
    service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
  }
}
```

> **Breaking change:** The `service_endpoints_with_location` subnet field is no longer supported. Setting a non-null value fails validation. Use the names-only `service_endpoints` set instead; per-service locations are not configurable because Azure expands service endpoint locations implicitly.
