# terraform/modules/secrets/outputs.tf

output "secret_ids" {
  description = "Map of secret keys to their fully qualified IDs"
  value       = { for k, v in google_secret_manager_secret.this : k => v.id }
}
