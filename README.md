# platform-gcp-terraform-modules

Reusable, versioned Terraform module library for the GCP platform. Never applied directly —
consumed as pinned `source` references by repos that actually hold state (e.g. `infra-gcp-landing-zone`).

## What

- Library of standalone Terraform modules: naming/tagging, networking, IAM, compute, governance, API enablement
- No backend, no state, no `environments/` — a pure code dependency, like an internal npm package

## Why

- Single source of truth for naming/tagging logic (`common`) so every consuming repo produces
  consistent resource names without duplicating that logic
- Keeps blast-radius separation: this repo can be edited/reviewed without ever touching live infrastructure

## Where

- Upstream: nothing — this is the base of the dependency graph
- Downstream: `infra-gcp-landing-zone` and any future GCP repo that needs these building blocks,
  pulled in via `source = "git::https://github.com/<org>/platform-gcp-terraform-modules.git//modules/<name>?ref=vX.Y.Z"`

## Contains

- `modules/common` — naming/tagging engine (SSOT for resource names, labels, region tokens)
- `modules/vpc` — multi-VPC networking (subnets, routes, firewalls)
- `modules/iam` — service accounts + role bindings, driven by the SSOT workload map
- `modules/compute` — instance templates + managed instance groups (MIGs)
- `modules/governance` — org policies + VPC Service Controls
- `modules/project-services` — enables required GCP APIs on a project

## How

```hcl
module "common" {
  source = "git::https://github.com/<org>/platform-gcp-terraform-modules.git//modules/common?ref=v1.0.0"
  # ...
}
```

## Notes / Gotchas

- Always pin `?ref=` to a tag. Never consume from a branch — that reintroduces the drift risk
  this repo exists to prevent.
- If a consuming repo needs different behavior, add a variable to the shared module — do not fork it.
