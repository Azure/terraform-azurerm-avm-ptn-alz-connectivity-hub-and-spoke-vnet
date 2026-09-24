# Root outputs without `sensitive`, as the accelerator re-exports them: a leaked sensitive mark fails the plan.
output "direct_module" {
  value       = module.direct
  description = "Every output of the direct module call."
}

output "adapted_module" {
  value       = module.adapted
  description = "Every module output reached through the production adapter."
}
