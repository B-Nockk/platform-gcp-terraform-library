# terraform/modules/observability/variables.tf

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
# OBSERVABILITY CONFIGURATION
# ============================== ==============================

variable "dashboards" {
  description = "Custom Monitoring Dashboards (JSON representations)."
  type = map(object({
    json_config = string
  }))
  default = {}
}

variable "log_sinks" {
  description = "Log routing sinks."
  type = map(object({
    destination            = string # e.g. "storage.googleapis.com/my-bucket" or "pubsub.googleapis.com/projects/my/topics/t"
    filter                 = string # e.g. "severity >= ERROR"
    unique_writer_identity = optional(bool, true)
  }))
  default = {}
}
