# common

The naming/tagging engine — the SSOT every other module reads resource names and labels from.

## What

- Generates every resource name used across the platform from one set of inputs
- Sanitizes labels to meet GCP's strict naming rules (lowercase, hyphens, no spaces)
- Computes the state bucket name and the cross-repo outputs-registry path

## Why

- **Dependency inversion**: this module only ever receives _keys_ (`vpc_subnet_keys`, `workload_keys`),
  never the full VPC/workload schema — it doesn't need to know what a VPC or workload _is_, only that
  one exists and needs a name
- Guarantees every other module (vpc, iam, compute) derives names from the same source, so their
  outputs align without manual cross-referencing

## Where

- Upstream: nothing — this is the first module every environment calls
- Downstream: `vpc`, `iam`, `compute`, `governance` all consume `resource_computed_names`, `common_tags`, and/or `separators` from this module's outputs

## Contains

- `resource_type_token.tf` — abbreviation map (e.g. `vpc` → `vpc`, `subnet` → `snet`, `service_account` → `sa`)
- `resource_identifier.tf` — the `sep` separator map + the standard `resource_identifier` string (e.g. `lndzn-dev-euw1-01`)
- `resource_computed_names.tf` — the full naming catalogue (`resource_computed_names`) for VPCs, subnets, firewalls, routes, and per-workload resources; also computes the state bucket name and outputs-registry path
- `regions.tf` — GCP region → short-token map (EMEA-weighted, includes Africa South1 for latency to Nigeria)
- `tags.tf` — sanitized `common_tags` (project, environment, owner, managed_by, repository)
- `main.tf` — currently empty (all logic lives in locals/outputs files)

## Expects (Inputs)

| Name                                  | Type              | Required | Default | Description                                                          |
| ------------------------------------- | ----------------- | -------- | ------- | -------------------------------------------------------------------- |
| `project_name`                        | string            | yes      | —       | Platform project name                                                |
| `project_token`                       | string            | yes      | —       | Short-form project token used in resource identifiers                |
| `project_owner`                       | string            | yes      | —       | Project owner, sanitized into labels                                 |
| `project_id`                          | string            | yes      | —       | GCP project ID                                                       |
| `environment`                         | string            | yes      | —       | One of `local`, `dev`, `staging`, `prod` (validated)                 |
| `region_short`                        | string            | yes      | —       | Region abbreviation token                                            |
| `instance_id`                         | string            | yes      | —       | Alphanumeric uniqueness index (e.g. `001`)                           |
| `vpc_subnet_keys`                     | map(list(string)) | no       | `{}`    | VPC key → subnet key list, derived from the environment's `vpcs` var |
| `workload_keys`                       | list(string)      | no       | `[]`    | Workload keys, derived from the environment's `workloads` var        |
| `state_registry_prefix`               | string            | yes      | —       | GCS prefix for the cross-repo outputs registry                       |
| `state_bucket_prefix`                 | string            | yes      | —       | Prefix used to construct the state bucket name                       |
| `override_computed_state_bucket_name` | string            | no       | `""`    | Explicit override for the computed state bucket name                 |

## Returns (Outputs)

| Name                      | Type         | Description                                                           |
| ------------------------- | ------------ | --------------------------------------------------------------------- |
| `required_apis`           | list(string) | Master list of GCP APIs required across the landing zone              |
| `common_tags`             | map(string)  | Standard labels applied to all resources                              |
| `resource_identifier`     | string       | The 63-char-safe standard identifier                                  |
| `gcp_regions`             | map(object)  | Full region name → short token map                                    |
| `resource_computed_names` | object       | The full naming catalogue — every other module's names come from here |
| `separators`              | map(string)  | Centralized separator characters for naming joins                     |
| `state_bucket_name`       | string       | Resolved GCS bucket name for state + registry                         |

## Notes / Gotchas

- `allowed_resource_locations`-style "remove if not used" TODOs elsewhere in the platform should be
  checked against whether `common` needs an equivalent — currently it doesn't expose one.
- `main.tf` being empty is intentional, not a bug — everything lives in purpose-named files
  (`tags.tf`, `regions.tf`, etc.) for readability.
