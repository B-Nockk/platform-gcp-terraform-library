# terraform/modules/edge/outputs.tf

output "load_balancer_ip" {
  description = "The global IP address of the External Load Balancer."
  value       = google_compute_global_address.lb_ip.address
}

output "waf_policy_self_links" {
  description = "Self-links of the created Cloud Armor security policies."
  value       = { for k, v in google_compute_security_policy.this : k => v.self_link }
}
