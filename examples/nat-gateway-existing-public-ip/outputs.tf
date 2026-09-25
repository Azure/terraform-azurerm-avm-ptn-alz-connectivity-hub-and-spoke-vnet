output "public_ip_prefix_resource_id" {
  value       = azapi_resource.public_ip_prefix.id
  description = "The resource ID of the Public IP Prefix used by the NAT Gateway Public IP."
}

output "nat_public_ip_resource_id" {
  value       = azapi_resource.public_ip.id
  description = "The resource ID of the Public IP created from the Public IP Prefix."
}

output "nat_gateway_resource_id" {
  value       = module.test.nat_gateway_resource_ids["primary"]
  description = "The resource ID of the hub NAT Gateway."
}
