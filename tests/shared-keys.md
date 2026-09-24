# Shared Key Regression

The regression for Azure/Azure-Landing-Zones#337 runs as part of the standard repository unit tests. From the repository root, with PowerShell 7.4+, Git and Avm.Authoring installed:

```powershell
Import-Module Avm.Authoring
avm test unit
```

The existing [PR workflow](../.github/workflows/pr-check.yml) calls the [AVM reusable workflow](https://github.com/Azure/azure-verified-modules-tools/blob/main/.github/workflows/terraform-module.yml). Its `unit-test` job already executes `avm test unit`, which discovers `tests/unit/*.tftest.hcl` and invokes the supported [setup hook](unit/setup.ps1). No additional workflow, job or custom test runner is required.

The existing workflow's fork-PR restriction is unchanged: it only invokes the reusable workflow for non-fork PRs. These unit tests themselves use mocked Azure providers and synthetic values, without deploying Azure resources or reading Azure credentials. Initial setup downloads the managed tools, modules and providers.

A `mock_provider` block only replaces a provider that the tested root module declares in `required_providers` and does not configure inside a child module. An undeclared non-HashiCorp provider such as `Azure/azapi`, or a provider block in a child module, silently uses the real provider and any local Azure CLI login. The full multi-region example therefore declares `azapi` and `modtm`, with a line-level TFLint exception for `terraform_unused_required_providers` because only its called modules use them, and no fixture calls the example as a child module. Running the suite without an Azure CLI login, as CI does, reveals such leaks.

## Coverage

| Test | Runs | Regression contract |
| --- | --- | --- |
| [gateway_shared_keys.tftest.hcl](unit/gateway_shared_keys.tftest.hcl) | 2 | Resource-level shared/authorization-key values and sensitive marks, connection names/attributes, null/absent connections and existing local gateways. |
| [shared_keys.tftest.hcl](unit/shared_keys.tftest.hcl) | 1 | Leaf-sensitive shared keys supplied directly: gateway, route and Bastion membership, default IP allocation, NAT IPs, custom DNS links and public outputs. |
| [services_shared_keys.tftest.hcl](unit/services_shared_keys.tftest.hcl) | 4 | Ordinary and leaf-sensitive controls with Firewall, Firewall Policy, DNS Resolver and Resolver Policy enabled; business domain values retain sensitivity. |
| [dns_sensitivity.tftest.hcl](unit/dns_sensitivity.tftest.hcl) | 6 | Custom/null/empty default links, nested links and overrides, public identities and nonempty resolution-policy mark retention. |
| [nat_sensitivity.tftest.hcl](unit/nat_sensitivity.tftest.hcl) | 5 | Leaf-sensitive shared keys, created/existing IPv4/IPv6 IPs, original null/default behavior, public identities and business-tag mark retention. |
| [example_shared_keys.tftest.hcl](unit/example_shared_keys.tftest.hcl) | 1 | The reported #337 path: the actual example's four transformed secret paths, dynamic keys and complete configuration output protection; the example runs as root, so its undeclared `test_outputs` fails the plan on any leaked mark. |
| [unknown_shared_keys.tftest.hcl](unit/unknown_shared_keys.tftest.hcl) | 1 | Two hubs, computed unknown keys, both the direct root module call and the production adapter path, with route/Bastion/NAT/DNS enabled; every module output is re-exported without `sensitive`, as the accelerator does. |
| [shared_key_consumer.tftest.hcl](unit/shared_key_consumer.tftest.hcl) | 8 | Direct, adapter and whole-configuration templating inputs; known/unknown, rotated, null/empty and disabled scenarios; all four original input paths, sensitive marks and cross-run public identity comparisons. The whole-configuration run also enables the service graph with a caller `custom_iterator` DNS zone. |
| [template_shared_keys.tftest.hcl](unit/template_shared_keys.tftest.hcl) | 3 | Original-template golden comparison: escaping, string/boolean values, dynamic and duplicate keys, null and omitted containers. |
| [firewall_public_ip_ip_tags.tftest.hcl](unit/firewall_public_ip_ip_tags.tftest.hcl) | 2 | Existing firewall public-IP tag propagation and default behavior. |

All 33 runs are discovered by the standard unit command; none requires a second script or a separate CI flow.

Regression runs deliberately use `command = plan`. The [unknown fixture](unit/fixtures/unknown_shared_keys/main.tf) derives its four shared keys from built-in `terraform_data.output` values, which are unknown until apply. It calls the actual root module directly and through the production adapter copy, which is the example's own adapter and module call without its `azurerm` provider block. The example cannot receive unknown keys itself: as a child its provider block is not mocked, and Terraform test rejects unknown values passed from one run to the next. The assertions require gateway, connection, route, Bastion, NAT and DNS identities to remain plan-known. Its [outputs](unit/fixtures/unknown_shared_keys/outputs.tf) re-export both module calls without `sensitive`, so any leaked mark fails the plan. Applying the fixture first would resolve the unknowns and miss the planning failure.

The consumer matrix checks original and rotated values at all four input paths in both hubs. The adapter mode removes only the container mark of the fixture's sensitive child output, so the module receives the same leaf-marked configuration as in the example. The whole-configuration mode passes the unchanged config-templating result, whose whole value carries the secrets' marks. Known-value cases inspect leaf-sensitive marks before fixture output annotations are applied. With unknown templated values, those leaf-mark queries can themselves remain unknown; that case instead checks known topology and protection of the complete configuration output. The gateway unit tests separately assert resource values and sensitive marks.

The setup hook copies the current production adapter into the provider-configuration-free golden fixture, which the consumer and unknown-key fixtures load, and verifies its SHA256. The generated copy is ignored by Git and is never maintained separately. Only the test oracle pins the original config-templating revision; the production example retains its existing `ref=main`.

## Input Contract

The [module documentation](../README.md#gateway-shared-keys) defines which input shapes are supported. The tests cover each shape as follows.

| Input shape | Planning | Module outputs | Coverage |
| --- | --- | --- | --- |
| Leaf-sensitive secrets in a non-sensitive configuration, supplied directly or through the example adapter | Supported with known or unknown secrets | Re-exportable without `sensitive` | Direct-root, consumer direct/adapter, actual-example and unknown fixtures |
| Whole configuration serialized with a known secret inside | Supported | Configuration values stay sensitive; root re-exports need `sensitive = true` | Consumer `whole_json` run |
| Whole configuration serialized with an unknown secret inside | Not supported: the structure is already unknown when the module receives it | Not applicable | None; the caller must isolate secrets before serialization |

## Boundaries

Instance keys and enablement remain public, plan-time structure. Secret values come from the original fields; whole secret-bearing payloads and module outputs must not be declassified. The actual example's complete `config_outputs` is the only output declared sensitive. Its whole-module `test_outputs` stays undeclared, like the accelerator's `hub_and_spoke_vnet_full_output`, because the root output rule is what detects nested marks; `issensitive()` only checks the top level. Every other output declaration remains unchanged.

The DNS/NAT payload-mark tests override dependency outputs to inspect retained business-value marks. They do not claim that existing public outputs can return confidential business values.

This tier does not audit raw plan JSON, compare historical Git revisions or classify expected Terraform process failures. Those checks are not required to execute these unit tests, and the suite does not require a full-history checkout. An unknown secret left inside whole-configuration serialization remains outside the supported input contract.

## Example E2E Coverage

The default [full-multi-region E2E input](../examples/full-multi-region/test.auto.tfvars) enables ER/VPN gateways, DNS, NAT and Bastion, but configures no circuit connections, peerings, local gateway connections or shared keys. Its [pre-hook](../examples/full-multi-region/pre.ps1) only randomizes resource group names. A successful default E2E is therefore a non-secret network smoke test, not proof that #337 is fixed.

| Fix behavior | Repository unit coverage | Default full-multi-region E2E |
| --- | --- | --- |
| Four original shared-key paths and correct values | Gateway resource assertions, consumer matrix and actual-example assertions | No connection or peering inputs |
| Unknown keys before JSON/template processing | Plan-only direct and production-adapter fixtures, known-identity assertions and non-sensitive re-exports | No generated unknown keys |
| Whole-configuration templating with known secrets and enabled services | Consumer `whole_json` run, including a caller `custom_iterator` DNS zone | Inputs do not exercise sensitive propagation |
| Null/absent connections and public identity stability | Optional cases and cross-run identity comparisons | No positive secret-bearing control |
| Secret protection and public output shape | Native HCL assertions | No nonempty secret to check |
| Rotation | Native assertions for changed values, retained marks and unchanged identities | Not a key-rotation scenario |
| Remote key readback and Azure provisioning | Requires separate real-Azure verification | Not a secret-bearing readback scenario |

Real-Azure acceptance needs dedicated VPN, ER connection and ER peering inputs with generated keys, initial unknown-key plan inspection, correct destination binding, idempotency, rotation and cleanup. An ER circuit must be a dedicated provisioned test dependency. The ER local-gateway slot in mocked tests checks the existing input mapping; it is not a claim that every ER/IPsec combination is a supported Azure topology. No Azure E2E was executed as part of adding these unit tests.