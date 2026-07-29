# terraform/modules/observability/main.tf

# ============================== ==============================
# Dashboards
# ============================== ==============================

resource "google_monitoring_dashboard" "this" {
  for_each = var.dashboards

  project        = var.project_id
  dashboard_json = each.value.json_config
}

# ============================== ==============================
# Log Sinks
# ============================== ==============================

resource "google_logging_project_sink" "this" {
  for_each = var.log_sinks

  name                   = var.resource_computed_names.log_sinks[each.key]
  project                = var.project_id
  destination            = each.value.destination
  filter                 = each.value.filter
  unique_writer_identity = each.value.unique_writer_identity
}
