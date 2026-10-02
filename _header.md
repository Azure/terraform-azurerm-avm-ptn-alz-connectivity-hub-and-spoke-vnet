# Azure Landing Zones Platform Landing Zone Connectivity with Hub and Spoke Virtual Network

This module deploys a hub and spoke virtual network topology aligned to the Azure Landing Zones (ALZ) and Microsoft Cloud Adoption Framework (CAF) for Azure. The module is designed to be used in conjunction with the [Azure Verified Modules](https://aka.ms/AVM) initiative and is part of the [Microsoft Cloud Adoption Framework Azure Landing Zones](https://aka.ms/alz).

This module is leveraged by the [Azure Landing Zones IaC Accelerator](https://aka.ms/alz), head over there to learn more. It is part of the Azure Verified Modules for Platform Landing Zone (ALZ) set of modules.

> **Deprecation notice:** The `id` attribute on entries of the curated `virtual_networks` output (exposed by the `hub-virtual-network-mesh` submodule and consumed internally by this root module) is deprecated in favour of `resource_id` and will be removed in a future major version. New code should read `module.<name>.virtual_networks[<key>].resource_id` or use the top-level `resource_id` map output.

## Upgrading Azure Bastion

Azure Bastion now supports the `Premium` SKU through `hub_virtual_networks[*].bastion.private_only_enabled` and `hub_virtual_networks[*].bastion.session_recording_enabled`. Delivering this required upgrading the underlying `Azure/avm-res-network-bastionhost/azurerm` module from `0.6.0` to `0.9.0`, which moves the bastion host from the `azurerm` provider to the `azapi` provider and therefore changes its address in state.

Existing deployments with a bastion host must migrate state before applying, otherwise the host is destroyed and recreated, interrupting connectivity. For each hub key that has a bastion, add the following to your root configuration, apply once, then remove the blocks:

```terraform
removed {
  from = module.<your_module_name>.module.bastion_host["<hub_key>"].azurerm_bastion_host.this

  lifecycle {
    destroy = false
  }
}

import {
  id = "/subscriptions/<subscription_id>/resourceGroups/<resource_group_name>/providers/Microsoft.Network/bastionHosts/<bastion_name>"
  to = module.<your_module_name>.module.bastion_host["<hub_key>"].azapi_resource.bastion[0]
}
```

The child module sets `replace_triggers_external_values = [var.sku]` on the bastion resource. Because of [azapi#858](https://github.com/Azure/terraform-provider-azapi/issues/858), an import combined with that argument can still plan a replacement. Review the plan before applying and, if a replacement is proposed, either accept the recreate or complete the import against a copy of the child module with that argument temporarily removed.

Two other changes accompany this upgrade:

- `bastion.parent_id` is the new way to place the bastion host in a specific resource group, replacing the resource group name that was previously derived for the host. `bastion.resource_group_name` is still honoured for the bastion public IP.
- `bastion.copy_paste_enabled` now defaults to `true`, matching the upstream module. Setting it to `false` requires the `Standard` or `Premium` SKU.

