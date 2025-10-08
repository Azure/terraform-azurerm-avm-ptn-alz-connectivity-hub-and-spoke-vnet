locals {
  virtual_network_default_ip_prefix_size = 22
  virtual_network_subnet_default_ip_prefix_sizes = {
    bastion             = 26
    firewall            = 26
    firewall_management = 26
    gateway             = 27
    dns_resolver        = 28
  }
}

locals {
  virtual_network_default_ip_prefix_input = {
    for key, value in var.hub_virtual_networks : key => {
      address_space = value.default_hub_address_space == null ? "10.${index(keys(var.hub_virtual_networks), key)}.0.0/16" : value.default_hub_address_space
      address_prefixes = {
        hub = local.virtual_network_default_ip_prefix_size
      }
    }
  }
}

module "virtual_network_ip_prefixes" {
  source   = "Azure/avm-utl-network-ip-addresses/azurerm"
  version  = "0.1.0"
  for_each = local.virtual_network_default_ip_prefix_input

  address_prefixes = each.value.address_prefixes
  address_space    = each.value.address_space
  enable_telemetry = var.enable_telemetry
}

locals {
  virtual_network_subnet_default_ip_prefix_input = {
    for key, value in module.virtual_network_ip_prefixes : key => {
      address_space    = value.address_prefixes["hub"]
      address_prefixes = local.virtual_network_subnet_default_ip_prefix_sizes
    }
  }
}

module "virtual_network_subnet_ip_prefixes" {
  source   = "Azure/avm-utl-network-ip-addresses/azurerm"
  version  = "0.1.0"
  for_each = local.virtual_network_subnet_default_ip_prefix_input

  address_prefixes = each.value.address_prefixes
  address_space    = each.value.address_space
  enable_telemetry = var.enable_telemetry
}

locals {
  virtual_network_default_ip_prefixes = {
    for key, value in module.virtual_network_ip_prefixes : key => value.address_prefixes["hub"]
  }
  virtual_network_subnet_default_ip_prefixes = {
    for key, value in module.virtual_network_subnet_ip_prefixes : key => value.address_prefixes
  }
}