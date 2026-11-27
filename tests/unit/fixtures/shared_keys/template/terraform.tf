terraform {
  required_version = ">= 1.12, < 2.0"

  required_providers {
    # tflint-ignore: terraform_unused_required_providers
    azapi = {
      source = "Azure/azapi"
    }
    # tflint-ignore: terraform_unused_required_providers
    azurerm = {
      source = "hashicorp/azurerm"
    }
    # tflint-ignore: terraform_unused_required_providers
    modtm = {
      source = "Azure/modtm"
    }
    # tflint-ignore: terraform_unused_required_providers
    random = {
      source = "hashicorp/random"
    }
  }
}
