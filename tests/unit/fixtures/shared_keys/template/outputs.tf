output "configuration" {
  description = "Reconstructed configuration from the production adapter."
  sensitive   = true
  value       = local.templated_config.hub_virtual_networks
}

output "equivalent" {
  description = "Whether the structured values and types match the original template."
  value       = nonsensitive(local.templated_config == module.original.outputs)
}

output "original" {
  description = "Unmodified template result for golden comparisons."
  sensitive   = true
  value       = module.original.outputs.hub_virtual_networks
}
