output "config_outputs" {
  sensitive = true
  value = {
    custom_replacements = module.config.custom_replacements
    outputs             = local.templated_config
  }
}

output "linting" {
  value = {
    connectivity_type = var.connectivity_type
  }
}

output "test_outputs" {
  sensitive = true
  value     = module.test
}
