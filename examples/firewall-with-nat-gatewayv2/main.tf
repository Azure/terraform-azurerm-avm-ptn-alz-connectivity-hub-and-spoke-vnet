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
      name     = "rg-hub-fw-natgw-${random_string.suffix.result}"
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

      # Azure Firewall configuration with NAT Gateway assigned to the firewall subnet
      firewall = {
        sku_tier = "Standard"
        # Assign the generated NAT Gateway to the Azure Firewall subnet
        firewall_subnet_nat_gateway = {
          assign_generated_nat_gateway = true
        }
      }

      firewall_policy = {
        sku = "Standard"
      }

      # NAT Gateway Standard v2 with multiple public IPs
      nat_gateway = {
        sku                     = "StandardV2"
        idle_timeout_in_minutes = 10
        ip_configurations = {
          # Primary public IP
          primary = {
            is_default                 = true
            public_ip_creation_enabled = true
            public_ip_configuration = {
              name              = "pip-natgw-fw-primary"
              sku               = "StandardV2"
              allocation_method = "Static"
            }
          }
          # Secondary public IP for additional outbound capacity
          secondary = {
            is_default                 = false
            public_ip_creation_enabled = true
            public_ip_configuration = {
              name              = "pip-natgw-fw-secondary"
              sku               = "StandardV2"
              allocation_method = "Static"
            }
          }
          # Tertiary public IP for even more outbound capacity
          tertiary = {
            is_default                 = false
            public_ip_creation_enabled = true
            public_ip_configuration = {
              name              = "pip-natgw-fw-tertiary"
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
