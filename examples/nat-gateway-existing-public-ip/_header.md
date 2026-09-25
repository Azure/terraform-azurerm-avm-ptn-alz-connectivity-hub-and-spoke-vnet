# NAT Gateway with an Existing Public IP from a Prefix

This example creates a StandardV2 Public IP Prefix and a StandardV2 Public IP from that prefix, then reuses the Public IP on the pattern module's StandardV2 NAT Gateway. The hub workload subnet is associated with the NAT Gateway.

Authenticate to Azure, then run `terraform init`, `terraform apply`, and `terraform destroy` in this directory. Set `location` to an Azure region that supports StandardV2 Public IPs and NAT Gateways if needed.
