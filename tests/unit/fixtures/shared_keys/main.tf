resource "terraform_data" "key" {
  for_each = toset(["er_connection", "er_peering", "er_local", "vpn_connection"])

  input = var.shared_keys[each.key]
}

module "sut" {
  source = "../../../.."

  enable_telemetry     = false
  hub_virtual_networks = local.input_hub_virtual_networks
}

module "template" {
  source = "./template"

  hub_virtual_networks = local.hub_virtual_networks
}