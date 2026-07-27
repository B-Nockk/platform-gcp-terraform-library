# terraform/modules/artifact-registry/variables.tf

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for the registry"
  type        = string
}

variable "common_tags" {
  description = "Common labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "resource_computed_names" {
  description = "Computed names from the common module"
  type        = any
}

variable "workload_service_account_emails" {
  description = "Map of workload keys to their service account emails, sourced from landing-zone outputs"
  type        = map(string)
  default     = {}
}

variable "repositories" {
  description = "Map of repositories to create"
  type = map(object({
    format      = string
    description = string
    readers     = optional(list(string), [])
    writers     = optional(list(string), [])
  }))
  default = {}
}
