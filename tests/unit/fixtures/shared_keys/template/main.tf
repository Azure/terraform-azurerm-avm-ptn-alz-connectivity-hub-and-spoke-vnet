module "config" {
  source = "github.com/Azure/alz-terraform-accelerator//templates/platform_landing_zone/modules/config-templating?ref=36a03fce01628e502acc79a9208e2407229690b7"

  custom_replacements             = var.custom_replacements
  inputs                          = { hub_virtual_networks = local.hub_virtual_networks_template }
  starter_locations               = ["westeurope"]
  subscription_id_connectivity    = "00000000-0000-0000-0000-000000000000"
  subscription_id_identity        = "00000000-0000-0000-0000-000000000000"
  subscription_id_management      = "00000000-0000-0000-0000-000000000000"
  subscription_id_security        = "00000000-0000-0000-0000-000000000000"
  root_parent_management_group_id = "fixture-root"
}

module "original" {
  source = "github.com/Azure/alz-terraform-accelerator//templates/platform_landing_zone/modules/config-templating?ref=36a03fce01628e502acc79a9208e2407229690b7"

  custom_replacements             = var.custom_replacements
  inputs                          = { hub_virtual_networks = var.hub_virtual_networks }
  starter_locations               = ["westeurope"]
  subscription_id_connectivity    = "00000000-0000-0000-0000-000000000000"
  subscription_id_identity        = "00000000-0000-0000-0000-000000000000"
  subscription_id_management      = "00000000-0000-0000-0000-000000000000"
  subscription_id_security        = "00000000-0000-0000-0000-000000000000"
  root_parent_management_group_id = "fixture-root"
}