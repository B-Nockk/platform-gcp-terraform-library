# terraform/modules/edge/main.tf

# ============================== ==============================
# Cloud Armor (WAF)
# ============================== ==============================

resource "google_compute_security_policy" "this" {
  for_each = var.waf_policies

  name    = var.resource_computed_names.edge_waf_policies[each.key]
  project = var.project_id

  # Default rule (lowest priority)
  rule {
    action   = each.value.default_action
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default action"
  }

  # Custom Rules
  dynamic "rule" {
    for_each = each.value.rules
    content {
      action   = rule.value.action
      priority = rule.value.priority
      match {
        expr {
          expression = rule.value.match_expr
        }
      }
      description = rule.value.description
    }
  }
}

# ============================== ==============================
# SSL Certificates
# ============================== ==============================

resource "google_compute_managed_ssl_certificate" "this" {
  for_each = {
    for k, v in var.ssl_certificates : k => v
    if v.mode == "MANAGED"
  }

  name    = var.resource_computed_names.edge_ssl_certs[each.key]
  project = var.project_id

  managed {
    domains = each.value.managed_domains
  }
}

resource "google_compute_ssl_certificate" "this" {
  for_each = {
    for k, v in var.ssl_certificates : k => v
    if v.mode == "CUSTOM"
  }

  name        = var.resource_computed_names.edge_ssl_certs[each.key]
  project     = var.project_id
  certificate = each.value.custom_cert_body
  private_key = each.value.custom_cert_key

  lifecycle {
    create_before_destroy = true
  }
}

# Combine SSL cert self-links for the proxy
locals {
  ssl_certificate_links = concat(
    [for cert in google_compute_managed_ssl_certificate.this : cert.self_link],
    [for cert in google_compute_ssl_certificate.this : cert.self_link]
  )
}

# ============================== ==============================
# Backend Services
# ============================== ==============================

resource "google_compute_backend_service" "this" {
  for_each = var.backends

  name                  = var.resource_computed_names.edge_backends[each.key]
  project               = var.project_id
  protocol              = each.value.protocol
  port_name             = each.value.port_name
  timeout_sec           = each.value.timeout_sec
  health_checks         = [each.value.health_check]
  load_balancing_scheme = "EXTERNAL"

  security_policy = each.value.security_policy != null ? google_compute_security_policy.this[each.value.security_policy].self_link : null

  # Attach the MIGs from the landing zone dynamically
  dynamic "backend" {
    for_each = each.value.mig_self_links
    content {
      group           = backend.value
      balancing_mode  = "UTILIZATION"
      max_utilization = 0.8
      capacity_scaler = 1.0
    }
  }

  # Enable logging (IAP can be added later as requested)
  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

# ============================== ==============================
# URL Map (Routing)
# ============================== ==============================

resource "google_compute_url_map" "this" {
  name            = var.resource_computed_names.edge_lb.url_map
  project         = var.project_id
  default_service = google_compute_backend_service.this[var.routing.default_backend].self_link

  dynamic "host_rule" {
    for_each = var.routing.host_rules
    content {
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.value.path_matcher
    }
  }

  dynamic "path_matcher" {
    for_each = var.routing.path_matchers
    content {
      name            = path_matcher.key
      default_service = google_compute_backend_service.this[path_matcher.value.default_backend].self_link

      dynamic "path_rule" {
        for_each = path_matcher.value.path_rules
        content {
          paths   = path_rule.value.paths
          service = google_compute_backend_service.this[path_rule.value.backend].self_link
        }
      }
    }
  }
}

# ============================== ==============================
# Proxies & Forwarding Rules
# ============================== ==============================

# Global IP
resource "google_compute_global_address" "lb_ip" {
  name    = "${var.resource_computed_names.edge_lb.forwarding_rule}-ip"
  project = var.project_id
}

# HTTP Proxy (Optional, could redirect to HTTPS, but let's wire it to the URL map)
resource "google_compute_target_http_proxy" "this" {
  name    = "${var.resource_computed_names.edge_lb.target_proxy}-http"
  project = var.project_id
  url_map = google_compute_url_map.this.self_link
}

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${var.resource_computed_names.edge_lb.forwarding_rule}-http"
  project               = var.project_id
  target                = google_compute_target_http_proxy.this.self_link
  ip_address            = google_compute_global_address.lb_ip.address
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL"
}

# HTTPS Proxy (Conditionally created if SSL certs exist)
resource "google_compute_target_https_proxy" "this" {
  count = length(local.ssl_certificate_links) > 0 ? 1 : 0

  name             = "${var.resource_computed_names.edge_lb.target_proxy}-https"
  project          = var.project_id
  url_map          = google_compute_url_map.this.self_link
  ssl_certificates = local.ssl_certificate_links
}

resource "google_compute_global_forwarding_rule" "https" {
  count = length(local.ssl_certificate_links) > 0 ? 1 : 0

  name                  = "${var.resource_computed_names.edge_lb.forwarding_rule}-https"
  project               = var.project_id
  target                = google_compute_target_https_proxy.this[0].self_link
  ip_address            = google_compute_global_address.lb_ip.address
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL"
}
