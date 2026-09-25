terraform {
  required_version = "~> 1.12"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

data "azapi_client_config" "current" {}

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
}

resource "azapi_resource" "resource_group" {
  type      = "Microsoft.Resources/resourceGroups@2024-03-01"
  name      = "rg-natgw-existing-pip-${random_string.suffix.result}"
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  location  = var.location
  tags      = local.common_tags
}

resource "azapi_resource" "public_ip_prefix" {
  type      = "Microsoft.Network/publicIPPrefixes@2024-05-01"
  name      = "pipfx-natgw-${random_string.suffix.result}"
  parent_id = azapi_resource.resource_group.id
  location  = var.location

  tags = local.common_tags

  body = {
    sku = {
      name = "StandardV2"
      tier = "Regional"
    }
    properties = {
      prefixLength           = 28
      publicIPAddressVersion = "IPv4"
    }
  }
}

resource "azapi_resource" "public_ip" {
  type      = "Microsoft.Network/publicIPAddresses@2024-05-01"
  name      = "pip-natgw-${random_string.suffix.result}"
  parent_id = azapi_resource.resource_group.id
  location  = var.location

  tags = local.common_tags

  body = {
    sku = {
      name = "StandardV2"
      tier = "Regional"
    }
    properties = {
      publicIPAllocationMethod = "Static"
      publicIPAddressVersion   = "IPv4"
      publicIPPrefix = {
        id = azapi_resource.public_ip_prefix.id
      }
    }
  }
  tags = local.common_tags
}

module "test" {
  source = "../../"

  enable_telemetry = var.enable_telemetry
  hub_virtual_networks = {
    primary = {
      enabled_resources = {
        firewall                              = false
        firewall_policy                       = false
        bastion                               = false
        virtual_network_gateway_express_route = false
        virtual_network_gateway_vpn           = false
        private_dns_zones                     = false
        private_dns_resolver                  = false
        nat_gateway                           = true
      }

      location                  = var.location
      default_hub_address_space = "10.10.0.0/16"
      default_parent_id         = azapi_resource.resource_group.id

      hub_virtual_network = {
        address_space = ["10.10.0.0/16"]
        subnets = {
          workload = {
            name             = "snet-workload"
            address_prefixes = ["10.10.1.0/24"]
            nat_gateway = {
              assign_generated_nat_gateway = true
            }
            default_outbound_access_enabled = false
          }
        }
      }

      nat_gateway = {
        sku = "StandardV2"

        ip_configurations = {
          primary = {
            is_default                 = true
            public_ip_creation_enabled = false
            public_ip_configuration = {
              public_ip_existing_resource_id = azapi_resource.public_ip.id
            }
          }
        }
      }
    }
  }
}
