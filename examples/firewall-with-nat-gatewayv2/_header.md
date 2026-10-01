# Azure Firewall with NAT Gateway Example

This example demonstrates how to deploy an Azure Firewall with a NAT Gateway assigned to the firewall subnet. This configuration provides additional outbound SNAT port capacity for the firewall.

## Key Features

- **Azure Firewall Standard SKU**: Deployed with Standard tier firewall policy
- **NAT Gateway Standard v2**: Provides enhanced outbound connectivity with multiple public IPs
- **Multiple Public IPs**: Three public IPs attached to the NAT Gateway for increased SNAT port capacity
- **Firewall Subnet NAT Gateway Association**: The NAT Gateway is automatically associated with the Azure Firewall subnet

## Why Use NAT Gateway with Azure Firewall?

Azure Firewall has a limited number of SNAT ports per public IP (approximately 2,496 per IP). When you have high-volume outbound connections, you may experience SNAT port exhaustion. By associating a NAT Gateway with the Azure Firewall subnet:

1. **Increased SNAT Port Capacity**: NAT Gateway provides up to 64,000 SNAT ports per public IP
2. **Multiple Public IPs**: You can attach up to 16 public IPs to a single NAT Gateway
3. **Better Scalability**: Handle more concurrent outbound connections without SNAT exhaustion
4. **Automatic Failover**: NAT Gateway provides built-in redundancy

## Configuration Details

The example configures:

- NAT Gateway with `StandardV2` SKU for zone-redundancy support
- Three public IPs (`primary`, `secondary`, `tertiary`) for increased capacity
- `firewall_subnet_nat_gateway.assign_generated_nat_gateway = true` to associate the NAT Gateway with the firewall subnet

## Usage

```hcl
firewall = {
  sku_tier = "Standard"
  firewall_subnet_nat_gateway = {
    assign_generated_nat_gateway = true
  }
}

nat_gateway = {
  sku = "StandardV2"
  ip_configurations = {
    primary   = { is_default = true, ... }
    secondary = { ... }
    tertiary  = { ... }
  }
}
```
