# terraform/modules/secrets/main.tf

resource "google_secret_manager_secret" "this" {
  for_each = var.secrets

  secret_id = var.resource_computed_names.secrets[each.key]
  project   = var.project_id

  labels = var.common_tags

  replication {
    auto {}
  }
}

# Add placeholder versions if requested
resource "google_secret_manager_secret_version" "placeholder" {
  for_each = { for k, v in var.secrets : k => v if v.add_placeholder }

  secret      = google_secret_manager_secret.this[each.key].id
  secret_data = "placeholder-value-change-me" ## TODO:: secrets placeholder
}

# IAM bindings for accessors
locals {
  accessors = flatten([
    for secret_key, secret in var.secrets : [
      for sa_key in secret.accessors : {
        secret_key = secret_key
        sa_key     = sa_key
      }
    ]
  ])
}

resource "google_secret_manager_secret_iam_member" "accessors" {
  for_each = { for item in local.accessors : "${item.secret_key}-${item.sa_key}" => item }

  project   = var.project_id
  secret_id = google_secret_manager_secret.this[each.value.secret_key].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.workload_service_account_emails[each.value.sa_key]}"
}
