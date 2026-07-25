# project-services

Enables required GCP APIs on a project before dependent resources try to use them.

## What

- Turns on a list of GCP service APIs (e.g. `compute.googleapis.com`, `iam.googleapis.com`) for a given project

## Why

- Resources from `vpc`, `iam`, `compute`, etc. fail if their underlying API isn't enabled yet —
  this module exists so that enablement is explicit and happens first
- `disable_on_destroy = false` is deliberate: tearing down the environment shouldn't disable APIs
  out from under the project (avoids breaking the project on teardown)

## Where

- Upstream: none — typically the very first module applied in any environment, before `common`'s
  outputs are even needed by other modules
- Downstream: implicitly everything — `vpc`, `iam`, `compute`, `governance` all depend on their
  respective APIs being enabled first, though this isn't enforced via Terraform references (see Notes)

## Contains

- `main.tf` — `google_project_service`, one per API in `required_apis`

## Expects (Inputs)

| Name            | Type         | Required | Default | Description                                                           |
| --------------- | ------------ | -------- | ------- | --------------------------------------------------------------------- |
| `project_id`    | string       | yes      | —       | GCP project ID                                                        |
| `required_apis` | list(string) | yes      | —       | APIs to enable — typically fed from `common`'s `required_apis` output |

## Returns (Outputs)

<!-- TODO: no outputs.tf exists yet for this module -->

## Notes / Gotchas

- There's no explicit `depends_on` wiring this module's resources ahead of `vpc`/`iam`/`compute` in
  the environment root — if apply ordering issues ever show up, that's the first place to look
- Fed by `common.required_apis`, but nothing enforces that list stays in sync with what `vpc`/`iam`/
  `compute`/`governance` actually need — worth a periodic manual audit as new resource types are added
