# Regression test for Azure/Azure-Landing-Zones#4196
#
# `ip_tags` was absent from the firewall `public_ip_config` object type, so any caller
# value was silently discarded during type conversion and never reached the
# `avm-res-network-publicipaddress` module. Because `ip_tags` is immutable on
# `azurerm_public_ip`, that produced permanent drift and a failing destroy-and-recreate.

mock_provider "azurerm" {}
mock_provider "azapi" {}
mock_provider "random" {}
mock_provider "modtm" {}

run "ip_tags_reaches_default_and_management_public_ips" {
  command = plan

  module {
    source = "./modules/hub-virtual-network-mesh"
  }

  variables {
    enable_telemetry = false
    hub_virtual_networks = {
      primary = {
        name          = "vnet-hub-test"
        address_space = ["10.0.0.0/16"]
        location      = "westeurope"
        parent_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test"

        firewall = {
          sku_name              = "AZFW_VNet"
          sku_tier              = "Premium"
          subnet_address_prefix = "10.0.1.0/26"
          management_ip_enabled = true

          default_ip_configuration = {
            public_ip_config = {
              ip_tags = { FirstPartyUsage = "/Unprivileged" }
            }
          }
          management_ip_configuration = {
            public_ip_config = {
              ip_tags = { FirstPartyUsage = "/Unprivileged" }
            }
          }
        }
      }
    }
  }

  # HCL literal object constructors compare as objects, not maps; the actual
  # value flows through an `optional(map(string), {})` variable constraint, so
  # it must be compared as a map (tomap()), otherwise the assertion silently
  # evaluates to false ("LHS and RHS values are of different types").
  assert {
    condition     = try(output.firewall_public_ip_configurations.default["primary"].ip_tags, null) == tomap({ FirstPartyUsage = "/Unprivileged" })
    error_message = "ip_tags was not forwarded to the fw_default_ips public IP module."
  }

  assert {
    condition     = try(output.firewall_public_ip_configurations.management["primary"].ip_tags, null) == tomap({ FirstPartyUsage = "/Unprivileged" })
    error_message = "ip_tags was not forwarded to the fw_management_ips public IP module."
  }
}

run "ip_tags_defaults_to_empty_map" {
  command = plan

  module {
    source = "./modules/hub-virtual-network-mesh"
  }

  variables {
    enable_telemetry = false
    hub_virtual_networks = {
      primary = {
        name          = "vnet-hub-test"
        address_space = ["10.0.0.0/16"]
        location      = "westeurope"
        parent_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-test"

        firewall = {
          sku_name              = "AZFW_VNet"
          sku_tier              = "Standard"
          subnet_address_prefix = "10.0.1.0/26"
          management_ip_enabled = true

          # The mesh submodule does not apply its own defaults to these
          # objects (the root module's locals.firewall.tf merge() does that) —
          # when exercising the submodule directly they must be supplied
          # explicitly, even with no fields set, to avoid a null dereference.
          default_ip_configuration = {
            public_ip_config = {}
          }
          management_ip_configuration = {
            public_ip_config = {}
          }
        }
      }
    }
  }

  assert {
    condition     = try(length(output.firewall_public_ip_configurations.default["primary"].ip_tags), null) == 0
    error_message = "ip_tags should default to an empty map for default public IPs (backwards compatibility)."
  }

  assert {
    condition     = try(length(output.firewall_public_ip_configurations.management["primary"].ip_tags), null) == 0
    error_message = "ip_tags should default to an empty map for management public IPs (backwards compatibility)."
  }
}
