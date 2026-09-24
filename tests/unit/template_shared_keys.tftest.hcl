mock_provider "azurerm" {}
mock_provider "azapi" {
  source = "./tests/unit/mocks"
}
mock_provider "random" {}
mock_provider "modtm" {}

run "golden" {
  command = plan

  module {
    source = "./tests/unit/fixtures/shared_keys/template"
  }

  variables {
    custom_replacements = {
      names = { hub = "rendered-hub", circuit = "rendered/circuit", site = "rendered:site", flag = true }
    }
    hub_virtual_networks = {
      "$${hub}" = {
        data = ["true", "false", true, false, 42, null, [], {}]
        virtual_network_gateways = {
          express_route = {
            express_route_circuits = {
              "$${circuit}" = {
                connection = { shared_key = sensitive("escaped-\"quote\"-\\path-\n-$${site}") }
                peering    = { shared_key = sensitive("true") }
              }
              boolean = {
                connection = { shared_key = sensitive("$${flag}") }
                peering    = { shared_key = sensitive("false") }
              }
              null_key  = { connection = { shared_key = null } }
              empty_key = { connection = { shared_key = sensitive("") } }
              absent    = { connection = {}, peering = null }
              null_item = null
            }
            local_network_gateways = {
              "$${site}" = { connection = { shared_key = sensitive("er-$${site}") } }
            }
          }
          vpn = {
            local_network_gateways = {
              "$${site}" = { connection = { shared_key = sensitive("vpn-$${site}") } }
            }
          }
        }
      }
      omitted           = {}
      null_hub          = null
      null_gateways     = { virtual_network_gateways = null }
      null_gateway      = { virtual_network_gateways = { express_route = null, vpn = null } }
      null_collections  = { virtual_network_gateways = { express_route = { express_route_circuits = null, local_network_gateways = null } } }
      empty_collections = { virtual_network_gateways = { vpn = { local_network_gateways = {} } } }
    }
  }

  assert {
    condition     = output.equivalent
    error_message = "The production adapter must match the original template for dynamic keys, escaping, booleans, nulls, empty and omitted fields."
  }
}

run "null_input" {
  command = plan

  module {
    source = "./tests/unit/fixtures/shared_keys/template"
  }

  variables {
    hub_virtual_networks = null
  }

  assert {
    condition     = output.equivalent && output.configuration == null
    error_message = "A null input must retain its original template value."
  }
}

run "collision" {
  command = plan

  module {
    source = "./tests/unit/fixtures/shared_keys/template"
  }

  variables {
    custom_replacements = { names = { alias = "same" } }
    hub_virtual_networks = {
      same        = { virtual_network_gateways = { vpn = { local_network_gateways = { site = { connection = { shared_key = sensitive("first") } } } } } }
      "$${alias}" = { virtual_network_gateways = { vpn = { local_network_gateways = { site = { connection = { shared_key = sensitive("second") } } } } } }
    }
  }

  assert {
    condition     = output.equivalent
    error_message = "Accepted duplicate template keys must select the same complete value in both paths."
  }
}