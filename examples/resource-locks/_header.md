# Resource Locks Example

Exercises `CanNotDelete` resource locks on the resources that support them
(hub virtual network, Azure Firewall, Azure Firewall Policy, NAT Gateway,
Private DNS Zones resource group, Private DNS Resolver). Locks use the
default auto-generated name pattern:
`lock-<hub_virtual_networks_map_key>-<resource-type>-<lock-kind>`.

Because each lock is created by the same AVM module that owns its target
resource, Terraform's destroy graph removes the lock before the resource,
so `terraform destroy` (and test teardown) works without extra steps.
