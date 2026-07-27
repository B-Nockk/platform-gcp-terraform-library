# terraform/modules/workload-identity/variables.tf

variable "project_id" {
  description = "Project ID"
  type        = string
}

variable "resource_computed_names" {
  description = "Central computed naming map from the common module"
  type        = any
}

variable "wif_providers" {
  description = <<EOF
Map of Workload Identity Providers to configure. 
Keys must match those provided to the common module (wif_provider_keys).
Example:
  github = {
    issuer_uri = "https://token.actions.githubusercontent.com"
    attribute_mapping = {
      "google.subject"       = "assertion.sub"
      "attribute.actor"      = "assertion.actor"
      "attribute.repository" = "assertion.repository"
    }
    sa_bindings = {
      "attribute.repository/B-Nockk/apps-monorepo" = ["app", "web"]
    }
  }
EOF
  type = map(object({
    issuer_uri        = string
    attribute_mapping = map(string)
    sa_bindings       = map(list(string))
  }))
  default = {}
}

variable "workload_service_account_emails" {
  description = "Map of workload service account emails (from landing zone outputs)"
  type        = map(string)
  default     = {}
}
