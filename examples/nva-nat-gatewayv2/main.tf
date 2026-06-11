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
  # Define the NVA IP address - this would be the private IP of your NVA
  # In a real scenario, the NVA would be deployed in the trust subnet
  nva_private_ip = "10.0.0.4"
  resource_groups = {
    hub_primary = {
      name     = "rg-hub-nva-${random_string.suffix.result}"
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

# This is the module call
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
        # Disable Azure Firewall - we're using an NVA instead
        firewall                              = false
        firewall_policy                       = false
        bastion                               = false
        virtual_network_gateway_express_route = false
        virtual_network_gateway_vpn           = false
        private_dns_zones                     = false
        private_dns_resolver                  = false
        # Enable NAT Gateway
        nat_gateway = true
      }

      location                  = local.resource_groups["hub_primary"].location
      default_hub_address_space = "10.0.0.0/16"
      default_parent_id         = module.resource_groups["hub_primary"].resource_id

      hub_virtual_network = {
        address_space = ["10.0.0.0/24"]
        # Use the NVA IP address as the hub router for routing
        hub_router_ip_address = local.nva_private_ip

        # Enable the "firewall" route table (will route via NVA instead)
        route_table_firewall_enabled = true

        # Create custom user subnets
        subnets = {
          # Trust subnet - where NVA's internal interface would connect
          trust = {
            name             = "snet-trust"
            address_prefixes = ["10.0.0.0/26"]
            nat_gateway = {
              assign_generated_nat_gateway = true
            }
            route_table = {
              assign_generated_route_table = true
              route_table_reference_key    = "Firewall"
            }
            default_outbound_access_enabled = false
          }

          # Management subnet - for NVA management interface
          management = {
            name             = "snet-management"
            address_prefixes = ["10.0.0.64/26"]
            nat_gateway = {
              assign_generated_nat_gateway = true
            }
            route_table = {
              assign_generated_route_table = true
              route_table_reference_key    = "Firewall"
            }
            default_outbound_access_enabled = false
          }
        }
      }

      # NAT Gateway Standard v2 configuration
      nat_gateway = {
        sku                     = "StandardV2"
        idle_timeout_in_minutes = 10
        ip_configurations = {
          default = {
            is_default                 = true
            public_ip_creation_enabled = true
            public_ip_configuration = {
              name              = "pip-natgw-nva"
              sku               = "StandardV2"
              allocation_method = "Static"
            }
          }
        }
      }
    }
  }
  tags = local.common_tags
}
