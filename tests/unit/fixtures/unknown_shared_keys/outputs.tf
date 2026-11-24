# Root outputs without `sensitive`, as the accelerator re-exports them: a leaked sensitive mark fails the plan.
output "direct_module" {
  description = "Every output of the direct module call."
  value       = module.direct
}

output "adapted_module" {
  description = "Every module output reached through the production adapter."
  value       = module.adapted
}
