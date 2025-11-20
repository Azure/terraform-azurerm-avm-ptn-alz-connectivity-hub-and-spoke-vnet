locals {
  moved_block_template = <<MOVED_BLOCK
moved {
  from = ${var.private_link_private_dns_zone_virtual_network_link_moved_block_template_module_prefix}module.private_dns_zones["$${virtual_network_key}"].module.avm_res_network_privatednszone["$${dns_zone_key}"].azurerm_private_dns_zone_virtual_network_link.this["$${virtual_network_link_key}"]
  to   = ${var.private_link_private_dns_zone_virtual_network_link_moved_block_template_module_prefix}module.private_dns_zones["$${virtual_network_key}"].module.avm_res_network_privatednszone["$${dns_zone_key}"].module.virtual_network_links["$${virtual_network_link_key}"].azapi_resource.private_dns_zone_network_link
}
MOVED_BLOCK
  moved_blocks = flatten([for virtual_network_key, virtual_network_value in module.private_dns_zones : [
    for dns_zone_key, dns_zone_value in virtual_network_value.private_link_private_dns_zones_map : [
      for virtual_network_link_key, virtual_network_link_value in dns_zone_value.virtual_network_links :
      templatestring(local.moved_block_template, {
        virtual_network_key      = virtual_network_key
        dns_zone_key             = dns_zone_key
        virtual_network_link_key = virtual_network_link_key
      })
    ]
    ]
  ])
  moved_blocks_final = join("\n", local.moved_blocks)
}

# Manually added moved blocks
moved {
  from = module.private_dns_zone_auto_registration["primary"].azurerm_private_dns_zone_virtual_network_link.this["auto_registration"]
  to   = module.private_dns_zone_auto_registration["primary"].module.virtual_network_links["auto_registration"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zone_auto_registration["secondary"].azurerm_private_dns_zone_virtual_network_link.this["auto_registration"]
  to   = module.private_dns_zone_auto_registration["secondary"].module.virtual_network_links["auto_registration"].azapi_resource.private_dns_zone_network_link
}

# Auto-generated moved blocks for private DNS zone virtual network links
moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_acr_registry"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_acr_registry"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_acr_registry"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_acr_registry"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ai_cog_svcs"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ai_cog_svcs"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ai_cog_svcs"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ai_cog_svcs"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ai_oai"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ai_oai"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ai_oai"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ai_oai"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ai_services"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ai_services"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ai_services"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ai_services"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_aks_mgmt"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_aks_mgmt"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_aks_mgmt"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_aks_mgmt"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_api_management"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_api_management"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_api_management"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_api_management"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_app_configuration"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_app_configuration"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_app_configuration"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_app_configuration"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_app_service"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_app_service"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_app_service"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_app_service"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_arc_guest_configuration"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_arc_guest_configuration"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_arc_guest_configuration"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_arc_guest_configuration"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_arc_hybrid_compute"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_arc_hybrid_compute"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_arc_hybrid_compute"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_arc_hybrid_compute"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_arc_kubernetes"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_arc_kubernetes"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_arc_kubernetes"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_arc_kubernetes"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_attestation"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_attestation"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_attestation"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_attestation"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_automation"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_automation"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_automation"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_automation"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_avd_feed_mgmt"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_avd_feed_mgmt"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_avd_feed_mgmt"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_avd_feed_mgmt"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_avd_global"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_avd_global"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_avd_global"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_avd_global"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_backup"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_backup"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_backup"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_backup"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_batch"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_batch"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_batch"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_batch"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_bot_svc_bot"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_bot_svc_bot"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_bot_svc_bot"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_bot_svc_bot"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_bot_svc_token"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_bot_svc_token"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_bot_svc_token"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_bot_svc_token"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_container_apps"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_container_apps"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_container_apps"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_container_apps"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_analytical"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_analytical"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_analytical"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_analytical"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_cassandra"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_cassandra"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_cassandra"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_cassandra"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_gremlin"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_gremlin"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_gremlin"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_gremlin"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_mongo"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_mongo"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_mongo"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_mongo"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_mongo_vcore"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_mongo_vcore"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_mongo_vcore"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_mongo_vcore"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_postgres"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_postgres"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_postgres"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_postgres"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_sql"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_sql"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_sql"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_sql"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_table"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_table"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_table"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_cosmos_db_table"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_data_explorer"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_data_explorer"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_data_explorer"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_data_explorer"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_data_factory"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_data_factory"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_data_factory"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_data_factory"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_data_factory_portal"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_data_factory_portal"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_data_factory_portal"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_data_factory_portal"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_data_lake_gen2"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_data_lake_gen2"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_data_lake_gen2"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_data_lake_gen2"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_databricks_ui_api"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_databricks_ui_api"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_databricks_ui_api"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_databricks_ui_api"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_digital_twins"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_digital_twins"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_digital_twins"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_digital_twins"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_event_grid"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_event_grid"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_event_grid"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_event_grid"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_fabric"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_fabric"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_fabric"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_fabric"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_file_sync"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_file_sync"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_file_sync"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_file_sync"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_grafana"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_grafana"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_grafana"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_grafana"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_hdinsight"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_hdinsight"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_hdinsight"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_hdinsight"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_healthcare"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_healthcare"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_healthcare"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_healthcare"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_healthcare_dicom"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_healthcare_dicom"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_healthcare_dicom"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_healthcare_dicom"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_healthcare_fhir"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_healthcare_fhir"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_healthcare_fhir"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_healthcare_fhir"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_healthcare_workspaces"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_healthcare_workspaces"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_healthcare_workspaces"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_healthcare_workspaces"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_iot_central"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_iot_central"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_iot_central"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_iot_central"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_iot_hub"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_iot_hub"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_iot_hub"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_iot_hub"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_iot_hub_provisioning"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_iot_hub_provisioning"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_iot_hub_provisioning"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_iot_hub_provisioning"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_iot_hub_update"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_iot_hub_update"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_iot_hub_update"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_iot_hub_update"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_key_vault"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_key_vault"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_key_vault"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_key_vault"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_log_analytics"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_log_analytics"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_log_analytics"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_log_analytics"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_log_analytics_data"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_log_analytics_data"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_log_analytics_data"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_log_analytics_data"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_managed_hsm"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_managed_hsm"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_managed_hsm"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_managed_hsm"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_managed_prometheus"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_managed_prometheus"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_managed_prometheus"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_managed_prometheus"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_maria_db_server"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_maria_db_server"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_maria_db_server"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_maria_db_server"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_media_services_delivery"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_media_services_delivery"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_media_services_delivery"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_media_services_delivery"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_migration_service"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_migration_service"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_migration_service"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_migration_service"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ml"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ml"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ml"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ml"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ml_notebooks"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ml_notebooks"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ml_notebooks"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_ml_notebooks"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_monitor"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_monitor"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_monitor"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_monitor"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_monitor_agent"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_monitor_agent"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_monitor_agent"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_monitor_agent"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_mysql_db_server"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_mysql_db_server"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_mysql_db_server"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_mysql_db_server"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_postgres_sql_server"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_postgres_sql_server"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_postgres_sql_server"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_postgres_sql_server"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_power_bi_dedicated"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_power_bi_dedicated"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_power_bi_dedicated"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_power_bi_dedicated"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_power_bi_power_query"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_power_bi_power_query"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_power_bi_power_query"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_power_bi_power_query"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_power_bi_tenant_analysis"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_power_bi_tenant_analysis"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_power_bi_tenant_analysis"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_power_bi_tenant_analysis"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_purview_account"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_purview_account"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_purview_account"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_purview_account"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_purview_studio"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_purview_studio"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_purview_studio"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_purview_studio"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_redis_cache"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_redis_cache"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_redis_cache"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_redis_cache"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_redis_enterprise"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_redis_enterprise"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_redis_enterprise"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_redis_enterprise"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_search"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_search"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_search"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_search"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_service_hub"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_service_hub"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_service_hub"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_service_hub"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_signalr_service"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_signalr_service"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_signalr_service"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_signalr_service"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_site_recovery"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_site_recovery"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_site_recovery"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_site_recovery"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_sql_server"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_sql_server"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_sql_server"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_sql_server"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_1"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_1"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_1"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_1"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_2"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_2"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_2"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_2"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_3"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_3"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_3"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_3"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_4"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_4"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_4"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_4"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_5"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_5"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_5"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_static_web_apps_partitioned_5"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_blob"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_blob"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_blob"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_blob"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_file"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_file"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_file"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_file"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_queue"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_queue"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_queue"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_queue"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_table"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_table"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_table"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_table"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_web"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_web"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_web"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_storage_web"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_synapse"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_synapse"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_synapse"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_synapse"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_synapse_dev"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_synapse_dev"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_synapse_dev"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_synapse_dev"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_synapse_sql"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_synapse_sql"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_synapse_sql"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_synapse_sql"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_web_pubsub"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_web_pubsub"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_web_pubsub"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["primary"].module.avm_res_network_privatednszone["azure_web_pubsub"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_aks_mgmt"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_aks_mgmt"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_aks_mgmt"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_aks_mgmt"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_backup"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_backup"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_backup"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_backup"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_container_apps"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_container_apps"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_container_apps"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_container_apps"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_data_explorer"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_data_explorer"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_data_explorer"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_data_explorer"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_managed_prometheus"].azurerm_private_dns_zone_virtual_network_link.this["primary"]
  to   = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_managed_prometheus"].module.virtual_network_links["primary"].azapi_resource.private_dns_zone_network_link
}

moved {
  from = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_managed_prometheus"].azurerm_private_dns_zone_virtual_network_link.this["secondary"]
  to   = module.private_dns_zones["secondary"].module.avm_res_network_privatednszone["azure_managed_prometheus"].module.virtual_network_links["secondary"].azapi_resource.private_dns_zone_network_link
}
