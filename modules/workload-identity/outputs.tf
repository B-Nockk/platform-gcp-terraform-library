# terraform/modules/workload-identity/outputs.tf

output "workload_identity_pool_name" {
  description = "The fully qualified name of the workload identity pool."
  value       = length(google_iam_workload_identity_pool.this) > 0 ? google_iam_workload_identity_pool.this[0].name : null
}

output "workload_identity_provider_names" {
  description = "Map of created workload identity provider names."
  value       = { for k, v in google_iam_workload_identity_pool_provider.this : k => v.name }
}
