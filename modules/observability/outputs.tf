# terraform/modules/observability/outputs.tf

output "dashboard_ids" {
  description = "IDs of the created dashboards."
  value       = { for k, v in google_monitoring_dashboard.this : k => v.id }
}

output "log_sink_writer_identities" {
  description = "Writer identities of the log sinks (used to grant IAM permissions on the destination)."
  value       = { for k, v in google_logging_project_sink.this : k => v.writer_identity }
}
