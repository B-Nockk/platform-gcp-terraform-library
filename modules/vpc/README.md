# vpc

GCP-native, multi-VPC networking module. Scales to any number of VPCs/subnets without code changes.

## What

- Creates one or more VPC networks, each with their own regional subnets, routes, and firewall rules
- Enforces GCP's native topology: VPCs are global, subnets are regional

## Why

- A single `vpcs` map drives everything — adding a new VPC or subnet is a `.tfvars` change, not a code change
- Flattening pattern (`merge([...])` in `locals.tf`) resolves the parent-child `for_each` relationship
  GCP's provider doesn't handle natively for nested VPC → subnet/route/firewall structures

## Where

- Upstream: `common` (for `resource_computed_names`)
- Downstream: `compute` (consumes `subnet_ids` to attach VMs); `edge`/load-balancer stacks (consume VPC/subnet identifiers)

## Contains

- `main.tf` — VPC networks, subnets, routes
- `network_security_rules.tf` — firewall rules
- `locals.tf` — flattening of subnets, routes, and firewalls out of the nested `vpcs` map
- `outputs.tf` — VPC/subnet/firewall outputs

## Expects (Inputs)

| Name                      | Type        | Required | Default | Description                                                                                            |
| ------------------------- | ----------- | -------- | ------- | ------------------------------------------------------------------------------------------------------ |
| `project_id`              | string      | yes      | —       | GCP project ID                                                                                         |
| `common_tags`             | map(string) | yes      | —       | Platform standard labels                                                                               |
| `resource_computed_names` | object      | yes      | —       | Naming catalogue from `common` (VPC/subnet names, firewall/route prefixes)                             |
| `vpcs`                    | map(object) | yes      | —       | Per-VPC config: `routing_mode` (`GLOBAL`/`REGIONAL`, validated), `subnets`, `firewall_rules`, `routes` |

## Returns (Outputs)

| Name                  | Type         | Description                                                                 |
| --------------------- | ------------ | --------------------------------------------------------------------------- |
| `vpc_ids`             | map(string)  | VPC key → self_link (ID)                                                    |
| `vpc_names`           | map(string)  | VPC key → actual GCP name                                                   |
| `subnet_ids`          | map(string)  | `"{vpc}-{subnet}"` key → self_link (ID) — used by compute/GKE to attach VMs |
| `subnet_self_links`   | map(string)  | Same keys → self_link                                                       |
| `firewall_rule_names` | list(string) | All created firewall rule names                                             |

## Notes / Gotchas

- `routing_mode` is validated to be exactly `GLOBAL` or `REGIONAL` — anything else fails at plan time
- Firewall/route naming prefixes come from `common`, not from this module — do not hardcode a prefix here
- `subnet_ids` and `subnet_self_links` currently return identical values (`.id` and `.self_link` for
  GCP subnets often coincide in practice) — kept as separate outputs for consumer clarity
