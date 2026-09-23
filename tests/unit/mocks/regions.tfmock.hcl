mock_data "azapi_resource_action" {
  defaults = {
    output = {
      value = [{
        name        = "westeurope"
        displayName = "West Europe"
        metadata = {
          geography      = "Europe"
          regionCategory = "Recommended"
          regionType     = "Physical"
          pairedRegion   = [{ name = "northeurope" }]
        }
        availabilityZoneMappings = [{ logicalZone = "1" }, { logicalZone = "2" }, { logicalZone = "3" }]
      }]
    }
  }
}