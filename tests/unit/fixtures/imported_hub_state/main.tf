terraform {
  required_version = "~> 1.12"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
  }
}

# Mirrors the hub mesh module addresses so a later run can adopt this state.
module "hub_virtual_networks" {
  source   = "./virtual-network"
  for_each = toset(["primary"])
}

module "hub_virtual_network_subnets" {
  source   = "./subnet"
  for_each = toset(["primary-app"])

  parent_id = module.hub_virtual_networks["primary"].resource_id
}

output "imported_peerings" {
  description = "The Azure-returned peering collection in the synthetic imported state."
  value       = module.hub_virtual_networks["primary"].resource.body.properties.virtualNetworkPeerings
}

output "imported_subnets" {
  description = "The Azure-returned subnet collection in the synthetic imported state."
  value       = module.hub_virtual_networks["primary"].resource.body.properties.subnets
}

output "subnet_resource_id" {
  description = "The independently managed subnet resource ID."
  value       = module.hub_virtual_network_subnets["primary-app"].resource_id
}

output "virtual_network_resource_id" {
  description = "The imported hub virtual network resource ID."
  value       = module.hub_virtual_networks["primary"].resource_id
}
