package Azure_Proactive_Resiliency_Library_v2
import rego.v1

exception contains rules if {
  rules = [
    "virtual_network_gateway_use_zone_redundant_sku",
    "public_ip_use_standard_sku_and_zone_redundant_ip",
    "deploy_azure_firewall_across_multiple_availability_zones"
  ]
}
