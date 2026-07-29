# terraform/modules/edge/variables.tf

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "resource_computed_names" {
  description = "Centralized naming catalogue from the common module."
  type        = any
}

variable "common_tags" {
  description = "Common labels for all resources."
  type        = map(string)
}

# ============================== ==============================
# EDGE CONFIGURATION
# ============================== ==============================

variable "waf_policies" {
  description = "Cloud Armor WAF configurations."
  type = map(object({
    default_action = string # "allow" or "deny(403)"
    rules = list(object({
      priority    = number
      action      = string
      match_expr  = string # e.g. "request.headers['host'].exactMatch('example.com')"
      description = string
    }))
  }))
  default = {}
}

variable "ssl_certificates" {
  description = "SSL Certificate configurations."
  type = map(object({
    mode             = string                 # "MANAGED" or "CUSTOM"
    managed_domains  = optional(list(string)) # Used if mode is MANAGED
    custom_cert_body = optional(string)       # Used if mode is CUSTOM
    custom_cert_key  = optional(string)       # Used if mode is CUSTOM
  }))
  default = {}
}

variable "backends" {
  description = "Backend services representing the upstream workloads."
  type = map(object({
    protocol    = string # HTTP, HTTPS, HTTP2
    port_name   = string
    timeout_sec = optional(number, 30)

    mig_self_links = list(string)
    health_check   = string # Self-link of the health check to use

    security_policy = optional(string) # Key linking to a WAF policy in waf_policies
  }))
  default = {}
}

variable "routing" {
  description = "URL Map routing logic connecting frontends to backends."
  type = object({
    default_backend = string # Key linking to var.backends

    host_rules = optional(map(object({
      hosts        = list(string)
      path_matcher = string
    })), {})

    path_matchers = optional(map(object({
      default_backend = string # Key linking to var.backends
      path_rules = optional(map(object({
        paths   = list(string)
        backend = string # Key linking to var.backends
      })), {})
    })), {})
  })
}
