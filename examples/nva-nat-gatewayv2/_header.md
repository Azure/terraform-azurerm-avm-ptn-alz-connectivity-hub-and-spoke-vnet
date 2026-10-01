# NVA with NAT Gateway Example

This example demonstrates how to deploy a hub network configured for a Network Virtual Appliance (NVA) scenario instead of Azure Firewall. It includes:

- **NAT Gateway Standard v2**: Provides outbound internet connectivity for the subnets
- **Trust subnet**: Where the NVA's internal/trusted interface would connect (10.0.3.0/24)
- **Management subnet**: For NVA management access (10.0.4.0/24)
- **Route table**: Configured to route traffic via the NVA IP address

## Key Configuration

- Azure Firewall is disabled (`firewall = false`)
- The `hub_router_ip_address` is set to the NVA's private IP, which enables the firewall route table creation with the NVA as the next hop
- Both subnets use `route_table_reference_key = "Firewall"` to use the generated route table
- Both subnets have the NAT Gateway assigned using `assign_generated_nat_gateway = true`
- Custom routes are added via `route_table_entries_firewall` to direct traffic to the NVA

## Usage

After deploying this example, you would typically:

1. Deploy your NVA in the trust subnet with the IP specified in `nva_private_ip`
2. Configure the NVA's management interface in the management subnet
3. Peer spoke virtual networks to this hub
4. Configure the NVA with appropriate security policies
