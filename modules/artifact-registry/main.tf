# terraform/modules/artifact-registry/main.tf

resource "google_artifact_registry_repository" "this" {
  for_each = var.repositories

  location      = var.region
  repository_id = var.resource_computed_names.artifact_registries[each.key]
  description   = each.value.description
  format        = each.value.format
  project       = var.project_id

  labels = var.common_tags
}

# IAM bindings for readers
locals {
  # Flatten readers
  readers = flatten([
    for repo_key, repo in var.repositories : [
      for sa_key in repo.readers : {
        repo_key = repo_key
        sa_key   = sa_key
      }
    ]
  ])

  # Flatten writers
  writers = flatten([
    for repo_key, repo in var.repositories : [
      for sa_key in repo.writers : {
        repo_key = repo_key
        sa_key   = sa_key
      }
    ]
  ])
}

resource "google_artifact_registry_repository_iam_member" "readers" {
  for_each = { for item in local.readers : "${item.repo_key}-${item.sa_key}" => item }

  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.this[each.value.repo_key].name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${var.workload_service_account_emails[each.value.sa_key]}"
}

resource "google_artifact_registry_repository_iam_member" "writers" {
  for_each = { for item in local.writers : "${item.repo_key}-${item.sa_key}" => item }

  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.this[each.value.repo_key].name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${var.workload_service_account_emails[each.value.sa_key]}"
}
