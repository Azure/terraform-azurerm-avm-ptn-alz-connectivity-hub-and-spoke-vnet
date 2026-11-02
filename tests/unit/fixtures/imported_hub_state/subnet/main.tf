terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
  }
}

resource "azapi_resource" "subnet" {
  count = 1

  name      = "snet-app"
  parent_id = var.parent_id
  type      = "Microsoft.Network/virtualNetworks/subnets@2024-07-01"
  body = {
    properties = {
      addressPrefixes  = ["10.0.1.0/24"]
      serviceEndpoints = []
    }
  }
  response_export_values = []
}

output "resource_id" {
  description = "The synthetic independently managed subnet resource ID."
  value       = azapi_resource.subnet[0].id
}
