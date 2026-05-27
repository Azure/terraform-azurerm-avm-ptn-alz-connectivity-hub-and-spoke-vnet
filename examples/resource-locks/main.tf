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
  lock = {
    kind = "CanNotDelete"
  }
  resource_groups = {
    hub_primary = {
      name     = "rg-hub-primary-${random_string.suffix.result}"
      location = "swedencentral"
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

# This is the module call. Locks are applied to every resource that supports
# them. Destroy works without additional cleanup because each lock is owned by
# the same AVM module as its target resource, so it is torn down first.
module "test" {
  source = "../../"

  enable_telemetry = false
  hub_and_spoke_networks_settings = {
    enabled_resources = {
      ddos_protection_plan = false
    }
  }
  hub_virtual_networks = {
    primary = {
      enabled_resources = {
        bastion                               = false
        virtual_network_gateway_express_route = false
        virtual_network_gateway_vpn           = false
        private_dns_zones                     = false
        nat_gateway                           = true
      }
      location                  = local.resource_groups["hub_primary"].location
      default_hub_address_space = "10.0.0.0/16"
      default_parent_id         = module.resource_groups["hub_primary"].resource_id

      hub_virtual_network = {
        lock                         = local.lock
        address_space                = ["10.0.0.0/22"]
        route_table_firewall_enabled = true
      }

      firewall = {
        lock     = local.lock
        sku_tier = "Standard"
        sku_name = "AZFW_VNet"
      }

      firewall_policy = {
        lock = local.lock
        sku  = "Standard"
      }

      nat_gateway = {
        lock                    = local.lock
        sku                     = "StandardV2"
        idle_timeout_in_minutes = 10
        ip_configurations = {
          default = {
            is_default                 = true
            public_ip_creation_enabled = true
            public_ip_configuration = {
              name              = "pip-natgw-locks"
              sku               = "StandardV2"
              allocation_method = "Static"
            }
          }
        }
      }

      private_dns_resolver = {
        lock                             = local.lock
        default_inbound_endpoint_enabled = true
      }
    }
  }
  tags = local.common_tags
}
