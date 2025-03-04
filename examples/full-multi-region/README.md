<!-- BEGIN_TF_DOCS -->
# Default example

This deploys the module in its simplest form.

```hcl
terraform {
  required_version = "~> 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.21"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  features {}
  alias = "connectivity"
}

variable "custom_replacements" {
  type = object({
    names                      = optional(map(string), {})
    resource_group_identifiers = optional(map(string), {})
    resource_identifiers       = optional(map(string), {})
  })
  default = {
    names                      = {}
    resource_group_identifiers = {}
    resource_identifiers       = {}
  }
  description = "Custom replacements"
}

variable "hub_and_spoke_vnet_settings" {
  type        = any
  default     = {}
  description = <<DESCRIPTION
The shared settings for the hub and spoke networks. This is where global resources are defined.

The following attributes are supported:

  - ddos_protection_plan: (Optional) The DDoS protection plan settings. Detailed information about the DDoS protection plan can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-ddosprotectionplan

DESCRIPTION
}

variable "hub_and_spoke_vnet_virtual_networks" {
  type = map(object({
    hub_virtual_network = any
    virtual_network_gateways = optional(object({
      subnet_address_prefix = string
      express_route         = optional(any)
      vpn                   = optional(any)
    }))
    private_dns_zones = optional(any)
    bastion           = optional(any)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of hub networks to create. 

The following attributes are supported:

  - hub_virtual_network: The hub virtual network settings. Detailed information about the hub virtual network can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-hubnetworking
  - virtual_network_gateways: (Optional) The virtual network gateway settings. Detailed information about the virtual network gateway can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-vnetgateway
  - private_dns_zones: (Optional) The private DNS zone settings. Detailed information about the private DNS zone can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-network-private-link-private-dns-zones
  - bastion: (Optional) The bastion host settings. Detailed information about the bastion can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-res-network-bastionhost/
  
DESCRIPTION
}

variable "management_resource_settings" {
  type        = any
  default     = {}
  description = <<DESCRIPTION
The settings for the management resources. Details of the settings can be found in the module documentation at https://registry.terraform.io/modules/Azure/avm-ptn-alz-management
DESCRIPTION
}

variable "management_group_settings" {
  type        = any
  default     = {}
  description = <<DESCRIPTION
The settings for the management groups. Details of the settings can be found in the module documentation at https://registry.terraform.io/modules/Azure/avm-ptn-alz
DESCRIPTION
}

variable "connectivity_type" {
  type        = string
  description = "The type of network connectivity technology to use for the private DNS zones"
  default     = "hub_and_spoke_vnet"
  validation {
    condition     = contains(values(local.const.connectivity), var.connectivity_type)
    error_message = "The connectivity type must be either 'hub_and_spoke_vnet', 'virtual_wan' or 'none'"
  }
}

variable "connectivity_resource_groups" {
  type = map(object({
    name     = string
    location = string
  }))
  default     = {}
  description = <<DESCRIPTION
A map of resource groups to create. These must be created before the connectivity module is applied.

The following attributes are supported:

  - name: The name of the resource group
  - location: The location of the resource group

DESCRIPTION
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = "Flag to enable/disable telemetry"
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

module "regions" {
  source                    = "Azure/avm-utl-regions/azurerm"
  version                   = "0.3.0"
  use_cached_data           = false
  availability_zones_filter = false
  recommended_filter        = false
  enable_telemetry          = var.enable_telemetry
}

data "azurerm_client_config" "current" {}

locals {
  regions = { for region in module.regions.regions_by_name : region.name => {
    display_name = region.display_name
    zones        = region.zones == null ? [] : region.zones
    }
  }
}

# Custom name replacements
locals {
  custom_names                = jsondecode(local.custom_names_json_final)
  custom_names_json           = tostring(jsonencode(var.custom_replacements.names))
  custom_names_json_final     = replace(replace(local.custom_names_json_templated, "\"[", "["), "]\"", "]")
  custom_names_json_templated = templatestring(local.custom_names_json, local.built_in_replacements)
}

locals {
  custom_name_replacements = merge(local.built_in_replacements, local.custom_names)
}

# Custom resource group identifiers
locals {
  custom_resource_group_identifiers                = jsondecode(local.custom_resource_group_identifiers_json_final)
  custom_resource_group_identifiers_json           = tostring(jsonencode(var.custom_replacements.resource_group_identifiers))
  custom_resource_group_identifiers_json_final     = replace(replace(local.custom_resource_group_identifiers_json_templated, "\"[", "["), "]\"", "]")
  custom_resource_group_identifiers_json_templated = templatestring(local.custom_resource_group_identifiers_json, local.custom_name_replacements)
}

locals {
  custom_resource_group_replacements = merge(local.custom_name_replacements, local.custom_resource_group_identifiers)
}

# Custom resource identifiers
locals {
  custom_resource_identifiers                = jsondecode(local.custom_resource_identifiers_json_final)
  custom_resource_identifiers_json           = tostring(jsonencode(var.custom_replacements.resource_identifiers))
  custom_resource_identifiers_json_final     = replace(replace(local.custom_resource_identifiers_json_templated, "\"[", "["), "]\"", "]")
  custom_resource_identifiers_json_templated = templatestring(local.custom_resource_identifiers_json, local.custom_resource_group_replacements)
}

# Resource Group Names
locals {
  resource_group_name_replacements = { for key, value in module.resource_groups : "connectivity_resource_group_${key}" => value.name }
}

locals {
  final_replacements   = merge(local.interim_replacements, local.resource_group_name_replacements)
  interim_replacements = merge(local.custom_resource_group_replacements, local.custom_resource_identifiers)
}

locals {
  hub_and_spoke_vnet_gateway_default_skus = { for key, value in local.regions : key => length(value.zones) == 0 ? {
    express_route = "Standard"
    vpn           = "VpnGw1"
    } : {
    express_route = "ErGw1AZ"
    vpn           = "VpnGw1AZ"
    }
  }
}

locals {
  const = {
    connectivity = {
      virtual_wan        = "virtual_wan"
      hub_and_spoke_vnet = "hub_and_spoke_vnet"
      none               = "none"
    }
  }
}

locals {
  connectivity_enabled                    = var.connectivity_type != local.const.connectivity.none
  connectivity_hub_and_spoke_vnet_enabled = var.connectivity_type == local.const.connectivity.hub_and_spoke_vnet
  connectivity_virtual_wan_enabled        = var.connectivity_type == local.const.connectivity.virtual_wan
}

locals {
  hub_and_spoke_vnet_settings                        = jsondecode(local.hub_and_spoke_vnet_settings_json_final)
  hub_and_spoke_vnet_settings_json                   = tostring(jsonencode(var.hub_and_spoke_vnet_settings))
  hub_and_spoke_vnet_settings_json_final             = replace(replace(local.hub_and_spoke_vnet_settings_json_templated, "\"[", "["), "]\"", "]")
  hub_and_spoke_vnet_settings_json_templated         = templatestring(local.hub_and_spoke_vnet_settings_json, local.final_replacements)
  hub_and_spoke_vnet_virtual_networks                = local.connectivity_hub_and_spoke_vnet_enabled ? jsondecode(local.hub_and_spoke_vnet_virtual_networks_json_final) : {}
  hub_and_spoke_vnet_virtual_networks_json           = tostring(jsonencode(var.hub_and_spoke_vnet_virtual_networks))
  hub_and_spoke_vnet_virtual_networks_json_final     = replace(replace(local.hub_and_spoke_vnet_virtual_networks_json_templated, "\"[", "["), "]\"", "]")
  hub_and_spoke_vnet_virtual_networks_json_templated = templatestring(local.hub_and_spoke_vnet_virtual_networks_json, local.final_replacements)
}

locals {
  connectivity_resource_groups                = jsondecode(local.connectivity_resource_groups_json_final)
  connectivity_resource_groups_json           = tostring(jsonencode(var.connectivity_resource_groups))
  connectivity_resource_groups_json_final     = replace(replace(local.connectivity_resource_groups_json_templated, "\"[", "["), "]\"", "]")
  connectivity_resource_groups_json_templated = templatestring(local.connectivity_resource_groups_json, local.interim_replacements)
}


module "resource_groups" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.0"

  for_each = local.connectivity_resource_groups

  name             = each.value.name
  location         = each.value.location
  enable_telemetry = var.enable_telemetry
  tags             = var.tags

  providers = {
    azurerm = azurerm.connectivity
  }
}


locals {
  built_in_replacements = {
    starter_location_01                                           = local.starter_location_01
    starter_location_02                                           = local.starter_location_02
    starter_location_01_availability_zones                        = jsonencode(local.regions[local.starter_location_01].zones)
    starter_location_02_availability_zones                        = jsonencode(try(local.regions[local.starter_location_02].zones, null))
    starter_location_01_virtual_network_gateway_sku_express_route = local.hub_and_spoke_vnet_gateway_default_skus[local.starter_location_01].express_route
    starter_location_02_virtual_network_gateway_sku_express_route = try(local.hub_and_spoke_vnet_gateway_default_skus[local.starter_location_02].express_route, null)
    starter_location_01_virtual_network_gateway_sku_vpn           = local.hub_and_spoke_vnet_gateway_default_skus[local.starter_location_01].vpn
    starter_location_02_virtual_network_gateway_sku_vpn           = try(local.hub_and_spoke_vnet_gateway_default_skus[local.starter_location_02].vpn, null)
    root_parent_management_group_id                               = data.azurerm_client_config.current.tenant_id
    subscription_id_connectivity                                  = data.azurerm_client_config.current.subscription_id
    subscription_id_identity                                      = data.azurerm_client_config.current.subscription_id
    subscription_id_management                                    = data.azurerm_client_config.current.subscription_id
  }
  starter_location_01 = "uksouth"
  starter_location_02 = "ukwest"
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"

  hub_and_spoke_networks_settings = local.hub_and_spoke_vnet_settings
  hub_virtual_networks            = local.hub_and_spoke_vnet_virtual_networks
  enable_telemetry                = var.enable_telemetry
  tags                            = var.tags

  providers = {
    azurerm = azurerm.connectivity
  }
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.5)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.21)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

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

Default: `true`

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

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/avm-utl-regions/azurerm

Version: 0.3.0

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