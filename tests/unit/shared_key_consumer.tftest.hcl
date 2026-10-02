mock_provider "azurerm" {}
mock_provider "azapi" {
  source = "./tests/unit/mocks"
}
mock_provider "random" {}
mock_provider "modtm" {}

run "known" {
  command = plan

  module {
    source = "./tests/unit/fixtures/shared_keys"
  }

  assert {
    condition = (
      toset(keys(output.public.virtual_networks)) == toset(["alpha-hub", "beta-hub"]) &&
      output.public.gateways == ["alpha-hub-express-route", "alpha-hub-vpn", "beta-hub-express-route", "beta-hub-vpn"] &&
      !issensitive(output.public) &&
      alltrue([
        for hub_key in ["alpha-hub", "beta-hub"] : (
          output.public.er_connections["${hub_key}-express-route"] == ["primary/one"] &&
          output.public.er_connections["${hub_key}-vpn"] == [] &&
          output.public.local_connections["${hub_key}-express-route"] == ["existing:one"] &&
          output.public.local_connections["${hub_key}-vpn"] == ["office:one"] &&
          output.public.local_gateways["${hub_key}-express-route"] == [] &&
          output.public.local_gateways["${hub_key}-vpn"] == ["office:one"]
        )
      ])
    )
    error_message = "Original hub and connection keys must survive without string parsing."
  }

  assert {
    condition = (
      alltrue([for shared_keys in values(output.shared_keys) : shared_keys == var.shared_keys]) &&
      alltrue([for marks in values(output.shared_key_sensitivity) : alltrue(values(marks))])
    )
    error_message = "Every hub must retain the value and sensitive mark of all four original shared-key fields."
  }
}

run "unknown" {
  command = plan

  module {
    source = "./tests/unit/fixtures/shared_keys"
  }

  variables {
    unknown_keys = true
  }

  assert {
    condition = (
      output.public == run.known.public &&
      !issensitive(output.public) &&
      alltrue([for marks in values(output.shared_key_sensitivity) : alltrue(values(marks))])
    )
    error_message = "Unknown shared keys must not make the resource topology unknown."
  }
}

run "template_known" {
  command = plan

  module {
    source = "./tests/unit/fixtures/shared_keys"
  }

  variables {
    input_mode = "template"
  }

  assert {
    condition = (
      output.template_equivalent &&
      output.public == run.known.public &&
      !issensitive(output.public) &&
      output.shared_keys == run.known.shared_keys &&
      alltrue([for marks in values(output.shared_key_sensitivity) : alltrue(values(marks))])
    )
    error_message = "The adapted template must match the original template without changing values or types."
  }

  assert {
    condition     = !issensitive(module.sut.virtual_network_resource_names["alpha-hub"])
    error_message = "Adapter output must leave configuration values returned through module outputs non-sensitive."
  }
}

run "template_unknown" {
  command = plan

  module {
    source = "./tests/unit/fixtures/shared_keys"
  }

  variables {
    input_mode   = "template"
    unknown_keys = true
  }

  assert {
    condition = (
      output.public == run.known.public &&
      !issensitive(output.public)
    )
    error_message = "Templating must preserve known public topology with unknown shared keys."
  }

  assert {
    condition     = issensitive(output.configuration)
    error_message = "The complete templated configuration must remain a sensitive output while its values are unknown."
  }
}

run "rotated" {
  command = plan

  module {
    source = "./tests/unit/fixtures/shared_keys"
  }

  variables {
    input_mode = "template"
    shared_keys = {
      er_connection  = "rotated-er-connection"
      er_peering     = "rotated-er-peering"
      er_local       = "rotated-er-local"
      vpn_connection = "rotated-vpn-connection"
    }
  }

  assert {
    condition = (
      output.template_equivalent &&
      output.public == run.known.public &&
      !issensitive(output.public) &&
      output.shared_keys != run.known.shared_keys &&
      alltrue([for shared_keys in values(output.shared_keys) : shared_keys == var.shared_keys]) &&
      alltrue([for marks in values(output.shared_key_sensitivity) : alltrue(values(marks))])
    )
    error_message = "Rotation must update all four secret values while preserving their sensitivity and every public instance key."
  }
}

run "null_empty" {
  command = plan

  module {
    source = "./tests/unit/fixtures/shared_keys"
  }

  variables {
    input_mode = "template"
    shared_keys = {
      er_connection  = null
      er_peering     = null
      er_local       = ""
      vpn_connection = "false"
    }
  }

  assert {
    condition = (
      output.template_equivalent &&
      output.public == run.known.public &&
      !issensitive(output.public) &&
      alltrue([
        for shared_keys in values(output.shared_keys) : {
          for key_kind, shared_key in shared_keys : key_kind => tostring(shared_key)
        } == var.shared_keys
      ]) &&
      alltrue([for marks in values(output.shared_key_sensitivity) : marks.er_local && marks.vpn_connection])
    )
    error_message = "Null and empty keys must not select another source or change their template type."
  }
}

run "disabled" {
  command = plan

  module {
    source = "./tests/unit/fixtures/shared_keys"
  }

  variables {
    unknown_keys     = true
    gateways_enabled = false
  }

  assert {
    condition = (
      output.public.virtual_networks == run.known.public.virtual_networks &&
      length(output.public.gateways) == 0 &&
      length(output.public.er_connections) == 0 &&
      length(output.public.local_connections) == 0 &&
      length(output.public.local_gateways) == 0
    )
    error_message = "A secret must not enable a disabled gateway or connection."
  }
}

# Known secrets left inside whole-configuration templating: the module plans, but its outputs keep the marks.
run "whole_json" {
  command = plan

  module {
    source = "./tests/unit/fixtures/shared_keys"
  }

  variables {
    input_mode         = "whole"
    services           = true
    user_iterator_zone = true
  }

  assert {
    condition = (
      output.public == run.known.public &&
      alltrue([
        for service in ["bastions", "firewalls", "nat_gateways", "resolvers", "route_tables"] : output.services[service] == ["alpha-hub", "beta-hub"]
      ]) &&
      toset(keys(output.services.dns_zones)) == toset(["alpha-hub", "beta-hub"]) &&
      alltrue([
        for hub_key in ["alpha-hub", "beta-hub"] : output.services.dns_zones[hub_key] == ["fixture", "iterated_one", "iterated_two"]
      ])
    )
    error_message = "Whole-configuration templating with known secrets must keep every public instance key, including private DNS zones expanded from a caller custom_iterator."
  }

  assert {
    condition     = output.shared_keys == run.known.shared_keys
    error_message = "Whole-configuration templating must preserve all four secret values."
  }

  assert {
    condition     = issensitive(module.sut.virtual_network_resource_names["alpha-hub"])
    error_message = "The module must not declassify configuration values returned through its outputs."
  }
}