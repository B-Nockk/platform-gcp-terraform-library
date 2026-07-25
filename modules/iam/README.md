# iam

Dynamic service account provisioning and least-privilege role binding, driven by the SSOT workload map.

## What

- Creates one Service Account per workload key
- Binds each SA to the exact GCP roles declared for that workload — nothing more

## Why

- Eliminates the insecure default Compute SA pattern — every workload gets its own least-privilege identity
- Reads names from `common`'s naming catalogue and roles from the same `workloads` map `compute` reads,
  so IAM and Compute can never drift out of sync with each other

## Where

- Upstream: `common` (for `resource_computed_names`)
- Downstream: `compute` (consumes `service_account_emails` to attach SAs to instance templates)

## Contains

- `main.tf` — `google_service_account` (one per workload) + `google_project_iam_member` (flattened role bindings)

## Expects (Inputs)

| Name                      | Type        | Required | Default | Description                                                                 |
| ------------------------- | ----------- | -------- | ------- | --------------------------------------------------------------------------- |
| `project_id`              | string      | yes      | —       | GCP project ID                                                              |
| `resource_computed_names` | object      | yes      | —       | Naming catalogue from `common` (only `workloads[*].service_account` used)   |
| `workloads`               | map(object) | yes      | —       | SSOT per-workload map: `description`, `iam.roles`, optional `compute` block |

## Returns (Outputs)

| Name                     | Type        | Description                          |
| ------------------------ | ----------- | ------------------------------------ |
| `service_account_emails` | map(string) | Workload key → Service Account email |

## Notes / Gotchas

- The `workloads` variable type here includes the full optional `compute` block even though `iam`
  never reads it — kept identical to the shape `compute` expects so both modules can be fed the same
  environment-level `var.workloads` without reshaping it per module.
- Role bindings are flattened via `merge([...])` so a workload with N roles produces N
  `google_project_iam_member` resources, keyed `"{workload}-{role}"`.
