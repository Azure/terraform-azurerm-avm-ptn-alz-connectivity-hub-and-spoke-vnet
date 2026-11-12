# Regression test for Azure/Azure-Landing-Zones#4039.
# Verifies that enabled_resources.firewall_policy controls creation of
# the module-managed Azure Firewall Policy independently of Azure Firewall.

mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "azurerm" {}

mock_provider "modtm" {}

mock_provider "random" {}

override_module {
  target = module.regions
  outputs = {
    regions_by_name = {
      eastus = {
        zones = ["1", "2", "3"]
      }
    }
  }
}

variables {
  enable_telemetry = false
}

run "firewall_enabled_policy_disabled" {
  command = plan

  variables {
    location = "eastus"

    hub_virtual_networks = {
      primary = {
        location          = "eastus"
        default_parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"

        enabled_resources = {
          firewall                              = true
          firewall_policy                       = false
          bastion                               = false
          virtual_network_gateway_express_route = false
          virtual_network_gateway_vpn           = false
          private_dns_zones                     = false
          private_dns_resolver                  = false
          dns_resolver_policy                   = false
          nat_gateway                           = false
        }
      }
    }
  }

  assert {
    condition     = local.firewalls["primary"] != null
    error_message = "Azure Firewall should remain enabled when only firewall_policy is disabled."
  }

  assert {
    condition     = local.firewall_policies["primary"] == null
    error_message = "Firewall policy must not be created when enabled_resources.firewall_policy is false."
  }
}

run "firewall_and_policy_enabled" {
  command = plan

  variables {
    location = "eastus"

    hub_virtual_networks = {
      primary = {
        location          = "eastus"
        default_parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"

        enabled_resources = {
          firewall                              = true
          firewall_policy                       = true
          bastion                               = false
          virtual_network_gateway_express_route = false
          virtual_network_gateway_vpn           = false
          private_dns_zones                     = false
          private_dns_resolver                  = false
          dns_resolver_policy                   = false
          nat_gateway                           = false
        }
      }
    }
  }

  assert {
    condition     = local.firewalls["primary"] != null
    error_message = "Azure Firewall should be created when enabled_resources.firewall is true."
  }

  assert {
    condition     = local.firewall_policies["primary"] != null
    error_message = "Firewall policy should be created when enabled_resources.firewall_policy is true."
  }
}

run "firewall_policy_disabled_with_external_policy_id" {
  command = plan

  variables {
    location = "eastus"

    hub_virtual_networks = {
      primary = {
        location          = "eastus"
        default_parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"

        enabled_resources = {
          firewall                              = true
          firewall_policy                       = false
          bastion                               = false
          virtual_network_gateway_express_route = false
          virtual_network_gateway_vpn           = false
          private_dns_zones                     = false
          private_dns_resolver                  = false
          dns_resolver_policy                   = false
          nat_gateway                           = false
        }

        firewall = {
          firewall_policy_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-policy/providers/Microsoft.Network/firewallPolicies/external-policy"
        }
      }
    }
  }

  assert {
    condition     = local.firewall_policies["primary"] == null
    error_message = "Module-managed firewall policy should remain disabled when an external firewall policy ID is supplied."
  }

  assert {
    condition     = local.firewalls["primary"].firewall_policy_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-policy/providers/Microsoft.Network/firewallPolicies/external-policy"
    error_message = "External firewall policy ID should be preserved when module-managed firewall policy creation is disabled."
  }
}
