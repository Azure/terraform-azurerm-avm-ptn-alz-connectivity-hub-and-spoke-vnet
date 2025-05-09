<!-- BEGIN_TF_DOCS -->
# Multi-Region with Azure Firewall Example

Uses the standard tfvars file for the multi-region with azure firewall scenario.

```hcl
terraform {
  required_version = "~> 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.21"
    }
  }
}

provider "azurerm" {
  features {}
}






data "azurerm_client_config" "current" {}

module "config" {
  source = "github.com/Azure/alz-terraform-accelerator//templates/platform_landing_zone/modules/config-templating?ref=main"

  connectivity_resource_groups        = var.connectivity_resource_groups
  custom_replacements                 = var.custom_replacements
  enable_telemetry                    = var.enable_telemetry
  hub_and_spoke_vnet_settings         = var.hub_and_spoke_vnet_settings
  hub_and_spoke_vnet_virtual_networks = var.hub_and_spoke_vnet_virtual_networks
  management_group_settings           = var.management_group_settings
  management_resource_settings        = var.management_resource_settings
  root_parent_management_group_id     = ""
  starter_locations                   = var.starter_locations
  subscription_id_connectivity        = data.azurerm_client_config.current.subscription_id
  subscription_id_identity            = data.azurerm_client_config.current.subscription_id
  subscription_id_management          = data.azurerm_client_config.current.subscription_id
  tags                                = var.tags
}

module "resource_groups" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.0"
  for_each = module.config.connectivity_resource_groups

  location         = each.value.location
  name             = each.value.name
  enable_telemetry = false
  tags             = module.config.tags
}

# Build an implicit dependency on the resource groups
locals {
  hub_and_spoke_vnet_settings         = merge(module.config.hub_and_spoke_vnet_settings, local.resource_groups)
  hub_and_spoke_vnet_virtual_networks = (merge({ vnets = module.config.hub_and_spoke_vnet_virtual_networks }, local.resource_groups)).vnets
  resource_groups = {
    resource_groups = module.resource_groups
  }
}

# This is the module call
module "test" {
  source = "../../"

  enable_telemetry                = false
  hub_and_spoke_networks_settings = local.hub_and_spoke_vnet_settings
  hub_virtual_networks            = local.hub_and_spoke_vnet_virtual_networks
  tags                            = module.config.tags
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.5)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.21)

## Resources

The following resources are used by this module:

- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_connectivity_resource_groups"></a> [connectivity\_resource\_groups](#input\_connectivity\_resource\_groups)

Description: A map of resource groups to create. These must be created before the connectivity module is applied.

The following attributes are supported:

  - name: The name of the resource group
  - location: The location of the resource group

Type:

```hcl
map(object({
    name     = string
    location = string
  }))
```

Default: `{}`

### <a name="input_connectivity_type"></a> [connectivity\_type](#input\_connectivity\_type)

Description: The type of network connectivity technology to use for the private DNS zones

Type: `string`

Default: `"hub_and_spoke_vnet"`

### <a name="input_custom_replacements"></a> [custom\_replacements](#input\_custom\_replacements)

Description: Custom replacements

Type:

```hcl
object({
    names                      = optional(map(string), {})
    resource_group_identifiers = optional(map(string), {})
    resource_identifiers       = optional(map(string), {})
  })
```

Default:

```json
{
  "names": {},
  "resource_group_identifiers": {},
  "resource_identifiers": {}
}
```

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: Flag to enable/disable telemetry

Type: `bool`

Default: `false`

### <a name="input_hub_and_spoke_vnet_settings"></a> [hub\_and\_spoke\_vnet\_settings](#input\_hub\_and\_spoke\_vnet\_settings)

Description: The shared settings for the hub and spoke networks. This is where global resources are defined.

The following attributes are supported:

  - ddos\_protection\_plan: (Optional) The DDoS protection plan settings. Detailed information about the DDoS protection plan can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-ddosprotectionplan

Type: `any`

Default: `{}`

### <a name="input_hub_and_spoke_vnet_virtual_networks"></a> [hub\_and\_spoke\_vnet\_virtual\_networks](#input\_hub\_and\_spoke\_vnet\_virtual\_networks)

Description: A map of hub networks to create.

The following attributes are supported:

  - hub\_virtual\_network: The hub virtual network settings. Detailed information about the hub virtual network can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-hubnetworking
  - virtual\_network\_gateways: (Optional) The virtual network gateway settings. Detailed information about the virtual network gateway can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-vnetgateway
  - private\_dns\_zones: (Optional) The private DNS zone settings. Detailed information about the private DNS zone can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-network-private-link-private-dns-zones
  - bastion: (Optional) The bastion host settings. Detailed information about the bastion can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-res-network-bastionhost/

Type:

```hcl
map(object({
    hub_virtual_network = any
    virtual_network_gateways = optional(object({
      subnet_address_prefix = string
      express_route         = optional(any)
      vpn                   = optional(any)
    }))
    private_dns_zones = optional(any)
    bastion           = optional(any)
  }))
```

Default: `{}`

### <a name="input_management_group_settings"></a> [management\_group\_settings](#input\_management\_group\_settings)

Description: The settings for the management groups. Details of the settings can be found in the module documentation at https://registry.terraform.io/modules/Azure/avm-ptn-alz

Type: `any`

Default: `{}`

### <a name="input_management_resource_settings"></a> [management\_resource\_settings](#input\_management\_resource\_settings)

Description: The settings for the management resources. Details of the settings can be found in the module documentation at https://registry.terraform.io/modules/Azure/avm-ptn-alz-management

Type: `any`

Default: `{}`

### <a name="input_starter_locations"></a> [starter\_locations](#input\_starter\_locations)

Description: The default for Azure resources. (e.g 'uksouth')

Type: `list(string)`

Default:

```json
[
  "uksouth",
  "ukwest"
]
```

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_linting"></a> [linting](#output\_linting)

Description: n/a

## Modules

The following Modules are called:

### <a name="module_config"></a> [config](#module\_config)

Source: github.com/Azure/alz-terraform-accelerator//templates/platform_landing_zone/modules/config-templating

Version: main

### <a name="module_resource_groups"></a> [resource\_groups](#module\_resource\_groups)

Source: Azure/avm-res-resources-resourcegroup/azurerm

Version: 0.2.0

### <a name="module_test"></a> [test](#module\_test)

Source: ../../

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->