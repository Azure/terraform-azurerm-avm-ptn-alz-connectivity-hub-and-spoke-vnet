output "domain_list_resource_ids" {
  description = "The resource IDs of the DNS resolver domain lists created alongside the policy, keyed by the input map key."
  value       = { for k, v in azapi_resource.domain_list : k => v.id }
}

output "name" {
  description = "The name of the DNS resolver policy."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The full AzAPI resource object for the DNS resolver policy."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the DNS resolver policy."
  value       = azapi_resource.this.id
}

output "security_rule_resource_ids" {
  description = "The resource IDs of the DNS resolver security rules, keyed by the input map key."
  value       = { for k, v in azapi_resource.security_rule : k => v.id }
}

output "virtual_network_link_resource_ids" {
  description = "The resource IDs of the DNS resolver policy virtual network links, keyed by the input map key."
  value       = { for k, v in azapi_resource.virtual_network_link : k => v.id }
}
