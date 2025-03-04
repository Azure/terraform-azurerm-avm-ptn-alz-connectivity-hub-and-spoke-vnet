module "regions" {
  source                    = "Azure/avm-utl-regions/azurerm"
  version                   = "0.3.0"
  use_cached_data           = false
  availability_zones_filter = false
  recommended_filter        = false
  enable_telemetry          = false
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
  hub_and_spoke_vnet_settings                        = jsondecode(local.hub_and_spoke_vnet_settings_json_final)
  hub_and_spoke_vnet_settings_json                   = tostring(jsonencode(var.hub_and_spoke_vnet_settings))
  hub_and_spoke_vnet_settings_json_final             = replace(replace(local.hub_and_spoke_vnet_settings_json_templated, "\"[", "["), "]\"", "]")
  hub_and_spoke_vnet_settings_json_templated         = templatestring(local.hub_and_spoke_vnet_settings_json, local.final_replacements)
  hub_and_spoke_vnet_virtual_networks                = jsondecode(local.hub_and_spoke_vnet_virtual_networks_json_final)
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

module "resource_groups" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.0"

  for_each = local.connectivity_resource_groups

  name             = each.value.name
  location         = each.value.location
  enable_telemetry = false
}