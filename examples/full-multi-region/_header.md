# Multi-Region with Azure Firewall Example

Uses the standard tfvars file for the multi-region with azure firewall scenario.

Gateway shared keys use the existing input fields. The example preserves their template substitutions, including transformed hub and connection keys, while keeping unknown shared keys out of the whole-configuration JSON conversion.

`config_outputs` retains its complete configuration and existing object shape, including the templated shared keys. It is now sensitive, so normal CLI output is redacted and downstream outputs that expose it must also be sensitive. This does not encrypt state, saved plans, or JSON output; protect those artifacts as secrets.
