# compute

Immutable instance templates + auto-healing managed instance groups (MIGs), data-driven per workload.

## What

- Creates a health check, instance template, and regional MIG for every workload that declares a `compute` block
- Supports both `fixed`-count and `percent`-based rolling update strategies via a shared profile library

## Why

- Instance templates are immutable blueprints — changes force `create_before_destroy`, never in-place mutation
- `update_profiles` lets small fleets use fixed-count rolling updates and large fleets use percent-based ones,
  without duplicating the MIG resource block — the `try(..., null)` pattern lets GCP silently ignore
  whichever profile type doesn't apply
- Reads its workload set from the same SSOT `workloads` map `iam` reads, so a workload's SA and its MIG
  can never point at different keys

## Where

- Upstream: `common` (naming), `vpc` (subnet self-links), `iam` (service account emails)
- Downstream: `edge`/load-balancer stacks (consume `instance_group_self_links` to wire backend services)

## Contains

- `main.tf` — health checks, instance templates, region instance group managers
- `locals.tf` — filters `var.workloads` down to only entries with a non-null `compute` block

## Expects (Inputs)

| Name                      | Type        | Required | Default | Description                                                                                                     |
| ------------------------- | ----------- | -------- | ------- | --------------------------------------------------------------------------------------------------------------- |
| `project_id`              | string      | yes      | —       | GCP project ID                                                                                                  |
| `region`                  | string      | yes      | —       | Region the fleet runs in                                                                                        |
| `common_tags`             | map(string) | yes      | —       | Platform standard labels                                                                                        |
| `resource_computed_names` | object      | yes      | —       | Naming catalogue (workload-scoped names only: instance_prefix, instance_template, instance_group, health_check) |
| `subnet_self_links`       | map(string) | yes      | —       | From the `vpc` module's outputs, keyed `"{vpc}-{subnet}"`                                                       |
| `service_account_emails`  | map(string) | yes      | —       | From the `iam` module's outputs                                                                                 |
| `workloads`               | map(object) | yes      | —       | SSOT per-workload map; only entries with a `compute` block produce a fleet                                      |
| `update_profiles`         | map(object) | yes      | —       | Named library of rolling-update profiles (fixed or percent-based)                                               |

## Returns (Outputs)

| Name                           | Type        | Description                                                                |
| ------------------------------ | ----------- | -------------------------------------------------------------------------- |
| `instance_template_ids`        | map(string) | Workload key → Instance Template ID                                        |
| `instance_template_self_links` | map(string) | Workload key → Instance Template self_link                                 |
| `instance_group_manager_ids`   | map(string) | Workload key → MIG ID                                                      |
| `instance_group_self_links`    | map(string) | Workload key → MIG self_link — needed by the Load Balancer backend service |
| `health_check_ids`             | map(string) | Workload key → Health Check ID                                             |
| `health_check_self_links`      | map(string) | Workload key → Health Check self_link                                      |

## Notes / Gotchas

- `subnetwork` lookup uses `"{vpc_key}-{subnet_key}"` — if that key doesn't exist in `subnet_self_links`,
  Terraform fails fast at plan time rather than silently falling back
- `initial_delay_sec = 300` on auto-healing is hardcoded (5 min boot grace period) — not currently exposed as a variable
