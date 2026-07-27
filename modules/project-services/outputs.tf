# modules/project-services/outputs.tf

output "id" {
  description = "An ID to depend on for downstream modules to ensure APIs are enabled."
  value       = time_sleep.wait_for_apis.id
}
