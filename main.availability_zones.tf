module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "0.5.2"

  availability_zones_filter = false
  enable_telemetry          = var.enable_telemetry
  recommended_filter        = false
  use_cached_data           = false
}

locals {
  availability_zones = {
    for key, value in var.hub_virtual_networks : key => module.regions.regions_by_name[value.location].zones == null ? [] : module.regions.regions_by_name[value.location].zones
  }
}
