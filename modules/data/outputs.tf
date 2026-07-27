# terraform/modules/data/outputs.tf

output "cloud_sql_connections" {
  description = "Map of Cloud SQL connection names"
  value       = { for k, v in google_sql_database_instance.this : k => v.connection_name }
}

output "redis_host_ips" {
  description = "Map of Redis instance IPs"
  value       = { for k, v in google_redis_instance.this : k => v.host }
}

output "filestore_ips" {
  description = "Map of Filestore IP addresses"
  value       = { for k, v in google_filestore_instance.this : k => v.networks[0].ip_addresses[0] }
}
