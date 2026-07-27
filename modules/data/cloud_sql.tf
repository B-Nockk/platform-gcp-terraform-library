# terraform/modules/data/cloud_sql.tf

# ------------------------------------------------------------------------------
# Cloud SQL
# ------------------------------------------------------------------------------

resource "random_password" "cloud_sql" {
  for_each = var.cloud_sql
  length   = 16
  special  = true
}

resource "google_sql_database_instance" "this" {
  for_each = var.cloud_sql

  name             = var.resource_computed_names.cloud_sql_instances[each.key]
  project          = var.project_id
  region           = var.region
  database_version = each.value.database_version

  settings {
    tier              = each.value.tier
    availability_type = each.value.availability_type

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_self_links[each.value.vpc_key]
    }

    user_labels = var.common_tags
  }

  deletion_protection = false # Set to false for dev/testing ease
}

resource "google_sql_user" "default" {
  for_each = var.cloud_sql

  name     = "postgres"
  instance = google_sql_database_instance.this[each.key].name
  password = random_password.cloud_sql[each.key].result
  project  = var.project_id
}

# We automatically inject the generated database password into Secret Manager
resource "google_secret_manager_secret" "sql_password" {
  for_each = var.cloud_sql

  secret_id = "${var.resource_computed_names.cloud_sql_instances[each.key]}-root-pass"
  project   = var.project_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "sql_password" {
  for_each = var.cloud_sql

  secret      = google_secret_manager_secret.sql_password[each.key].id
  secret_data = google_sql_user.default[each.key].password
}
