output "configuration" {
  value       = local.templated_config.hub_virtual_networks
  description = "Reconstructed configuration from the production adapter."
  sensitive   = true
}

output "equivalent" {
  value       = nonsensitive(local.templated_config == module.original.outputs)
  description = "Whether the structured values and types match the original template."
}

output "original" {
  value       = module.original.outputs.hub_virtual_networks
  description = "Unmodified template result for golden comparisons."
  sensitive   = true
}