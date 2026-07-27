# terraform/modules/artifact-registry/outputs.tf

output "repository_ids" {
  description = "Map of repository keys to their fully qualified IDs"
  value       = { for k, v in google_artifact_registry_repository.this : k => v.id }
}
