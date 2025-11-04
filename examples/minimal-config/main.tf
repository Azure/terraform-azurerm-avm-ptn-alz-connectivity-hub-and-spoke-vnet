terraform {
  required_version = "~> 1.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.21"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_string" "suffix" {
  length  = 4
  numeric = true
  special = false
  upper   = false
}

locals {
  common_tags = {
    created_by  = "terraform"
    project     = "Azure Landing Zones"
    owner       = "avm"
    environment = "demo"
  }
  resource_groups = {
    hub_primary = {
      name     = "rg-hub-primary-${random_string.suffix.result}"
      location = "swedencentral"
    }
    hub_secondary = {
      name     = "rg-hub-secondary-${random_string.suffix.result}"
      location = "ukwest"
    }
  }
}

module "resource_groups" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.0"
  for_each = local.resource_groups

  location         = each.value.location
  name             = each.value.name
  enable_telemetry = false
  tags             = local.common_tags
}

# This is the module call
module "test" {
  source = "../../"

  enable_telemetry = false
  hub_virtual_networks = {
    primary = {
      location = local.resource_groups["hub_primary"].location
      # default_hub_address_space = "10.0.0.0/16"
      default_parent_id = module.resource_groups["hub_primary"].resource_id
    }
    secondary = {
      location = local.resource_groups["hub_secondary"].location
      # default_hub_address_space = "10.1.0.0/16"
      default_parent_id = module.resource_groups["hub_secondary"].resource_id
    }
  }
  tags = local.common_tags
}
