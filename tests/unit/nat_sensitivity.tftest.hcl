mock_provider "azurerm" {}
mock_provider "azapi" {
  source = "./tests/unit/mocks"
}
mock_provider "random" {}
mock_provider "modtm" {}

variables {
  enable_telemetry = false
  tags             = {}
  hub_virtual_networks = {
    primary = {
      location          = "westeurope"
      default_parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-review"
      enabled_resources = {
        firewall                              = false
        firewall_policy                       = false
        private_dns_zones                     = false
        private_dns_resolver                  = false
        dns_resolver_policy                   = false
        bastion                               = false
        nat_gateway                           = true
        virtual_network_gateway_express_route = true
        virtual_network_gateway_vpn           = false
      }
      nat_gateway = {
        ip_configurations = { primary = {} }
      }
      virtual_network_gateways = {
        route_table_creation_enabled               = false
        route_table_gateway_firewall_route_enabled = false
        express_route = {
          express_route_circuits = {
            primary = {
              id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-review/providers/Microsoft.Network/expressRouteCircuits/lab"
              connection = { shared_key = sensitive("review-synthetic-key") }
            }
          }
        }
      }
    }
  }
}

run "control" {
  command = plan
}

run "sensitive_shared_key" {
  command = plan

  assert {
    condition     = keys(output.nat_gateways.primary.public_ip_addresses) == ["primary"]
    error_message = "A sensitive shared key must not change NAT public IP instance keys."
  }
}

run "mixed_ips" {
  command = plan

  variables {
    hub_virtual_networks = {
      for hub_key, hub in var.hub_virtual_networks : hub_key => merge(hub, {
        nat_gateway = {
          ip_configurations = {
            primary = {}
            existing_v4 = {
              public_ip_creation_enabled = false
              public_ip_configuration = {
                public_ip_existing_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-review/providers/Microsoft.Network/publicIPAddresses/existing-v4"
              }
            }
            existing_v6 = {
              public_ip_creation_enabled = false
              public_ip_configuration = {
                ip_version                     = "IPv6"
                public_ip_existing_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-review/providers/Microsoft.Network/publicIPAddresses/existing-v6"
              }
            }
          }
        }
      })
    }
  }

  assert {
    condition     = keys(output.nat_gateways.primary.public_ip_addresses) == ["primary"]
    error_message = "Existing IPv4/IPv6 addresses must not create new IP instances."
  }
}

run "null_nat" {
  command = plan

  variables {
    hub_virtual_networks = { for hub_key, hub in var.hub_virtual_networks : hub_key => merge(hub, { nat_gateway = null }) }
  }

  assert {
    condition     = keys(output.nat_gateways) == ["primary"] && length(output.nat_gateways.primary.public_ip_addresses) == 0
    error_message = "A null root NAT input must retain its existing enabled default configuration without creating IPs."
  }
}

run "payload_marks" {
  command = plan

  module {
    source = "./modules/hub-virtual-network-mesh"
  }

  override_module {
    target = module.nat_gateway["primary"]
    outputs = {
      resource_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-review/providers/Microsoft.Network/natGateways/nat-test"
      resource           = { name = "nat-test" }
      public_ip_resource = {}
    }
  }

  variables {
    hub_virtual_networks = {
      primary = {
        name          = "vnet-test"
        location      = "westeurope"
        parent_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-review"
        address_space = ["10.0.0.0/16"]
        nat_gateway = {
          tags              = { business = sensitive("nat-business-canary") }
          ip_configurations = { primary = {} }
        }
      }
    }
  }

  assert {
    condition     = issensitive(local.nat_gateways.primary.tags.business) && local.nat_gateways.primary.tags.business == "nat-business-canary"
    error_message = "Publishing NAT IP configuration must not remove a business tag's sensitive mark."
  }
}