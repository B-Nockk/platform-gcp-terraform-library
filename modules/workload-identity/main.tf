# terraform/modules/workload-identity/main.tf

# ------------------------------------------------------------------------------
# Workload Identity Pool
# ------------------------------------------------------------------------------
# We only create a single pool if any providers are defined.
resource "google_iam_workload_identity_pool" "this" {
  count = length(var.wif_providers) > 0 ? 1 : 0

  project                   = var.project_id
  workload_identity_pool_id = var.resource_computed_names.workload_identity_pool
  display_name              = "Global Workload Identity Pool"
  disabled                  = false
}

# ------------------------------------------------------------------------------
# Workload Identity Providers
# ------------------------------------------------------------------------------
resource "google_iam_workload_identity_pool_provider" "this" {
  for_each = var.wif_providers

  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.this[0].workload_identity_pool_id
  workload_identity_pool_provider_id = var.resource_computed_names.workload_identity_providers[each.key]
  display_name                       = "WIF Provider: ${each.key}"

  attribute_mapping   = each.value.attribute_mapping
  attribute_condition = each.value.attribute_condition != "" ? each.value.attribute_condition : null

  oidc {
    issuer_uri = each.value.issuer_uri
  }
}

# ------------------------------------------------------------------------------
# IAM Bindings (Service Account Impersonation)
# ------------------------------------------------------------------------------
# We flatten the nested map of github repositories to target GCP service accounts.
locals {
  sa_bindings_flat = flatten([
    for provider_key, provider_data in var.wif_providers : [
      for mapped_subject, target_sa_keys in provider_data.sa_bindings : [
        for sa_key in target_sa_keys : {
          id             = "${provider_key}-${mapped_subject}-${sa_key}"
          pool_id        = google_iam_workload_identity_pool.this[0].name
          mapped_subject = mapped_subject
          sa_email       = var.workload_service_account_emails[sa_key]
        }
      ]
    ]
  ])
}

resource "google_service_account_iam_member" "workload_identity_user" {
  for_each = { for b in local.sa_bindings_flat : b.id => b }

  service_account_id = "projects/${var.project_id}/serviceAccounts/${each.value.sa_email}"
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${each.value.pool_id}/${each.value.mapped_subject}"

  depends_on = [
    google_iam_workload_identity_pool_provider.this
  ]
}
