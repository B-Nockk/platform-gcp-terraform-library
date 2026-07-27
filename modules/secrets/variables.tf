# terraform/modules/secrets/variables.tf

variable "project_id" {
  description = "The GCP project ID"
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

variable "secrets" {
  description = "Map of secrets to create"
  type = map(object({
    description     = optional(string, "")
    add_placeholder = optional(bool, false)
    accessors       = optional(list(string), [])
  }))
  default = {}
}
