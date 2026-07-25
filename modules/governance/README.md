# governance

Project-level guardrails: Organization Policies and an optional VPC Service Controls data perimeter.

## What

- Enforces GCP Organization Policies at the project level (e.g. "no public IPs on VMs")
- Optionally creates a VPC Service Controls perimeter to prevent data exfiltration (e.g. restrict GCS access to only the platform's VPC)

## Why

- Org Policy `name` must match GCP's exact API string format (`projects/{id}/policies/{constraint}`) — encapsulated here so consumers never construct that string themselves
- VPC Service Controls is explicitly opt-in (`vpc_service_controls = null` by default) since it requires org-level resources most dev/local environments won't have

## Where

- Upstream: none beyond `project_id` — this module is intentionally low-dependency so it can be the
  closing/hardening phase of a landing zone without needing outputs from `vpc`/`iam`/`compute`
- Downstream: nothing consumes outputs from this module currently (see Notes)

## Contains

- `main.tf` — `google_org_policy_policy` (one per declared policy), `google_access_context_manager_access_policy` + `google_access_context_manager_service_perimeter` (conditional on `vpc_service_controls` being set)

## Expects (Inputs)

| Name                         | Type                            | Required | Default               | Description                                                                                  |
| ---------------------------- | ------------------------------- | -------- | --------------------- | -------------------------------------------------------------------------------------------- |
| `project_id`                 | string                          | yes      | —                     | GCP project ID                                                                               |
| `org_policies`               | map(object({ enforce = bool })) | yes      | —                     | No default on purpose — fail-fast, policies must be explicit in tfvars                       |
| `vpc_service_controls`       | object                          | no       | `null`                | Org ID, perimeter name, restricted services/resources. If `null`, VPC-SC is skipped entirely |
| `allowed_resource_locations` | list(string)                    | no       | `["in:eu-locations"]` | ⚠️ marked TODO — currently unused by any resource in this module                             |

## Returns (Outputs)

<!-- TODO: no outputs.tf exists yet for this module -->

## Notes / Gotchas

- `allowed_resource_locations` is declared but not wired to any resource — either implement a
  location-constraint policy that uses it, or remove the variable
- No `outputs.tf` exists yet — if a downstream stack ever needs the perimeter name or policy IDs,
  add outputs before consuming this module from `landing-zone`'s `environments/*/outputs_registry.tf`
- Designed to be the **last** module applied in a landing zone, after networking/IAM/compute exist —
  it locks down what earlier phases built rather than provisioning anything else depends on
