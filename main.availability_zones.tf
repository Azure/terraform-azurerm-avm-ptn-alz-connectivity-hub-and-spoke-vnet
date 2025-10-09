module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.5.2"
  count   = local.has_regions ? 1 : 0

  availability_zones_filter = false
  enable_telemetry          = var.enable_telemetry
  recommended_filter        = false
  use_cached_data           = false
}

locals {
  availability_zones = local.has_regions ? {
    for key, value in var.hub_virtual_networks : key => module.regions[0].regions_by_name[value.location].zones == null ? [] : module.regions[0].regions_by_name[value.location].zones
  } : null
}
