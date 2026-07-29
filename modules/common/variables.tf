# terraform/modules/common/variables.tf
variable "project_name" {
  description = "platform project name"
  type        = string
}
variable "project_token" {
  description = "platform project short-form token"
  type        = string
}

variable "project_owner" {
  description = "platform owner"
  type        = string
}

variable "project_id" {
  description = "project id"
  type        = string
}

variable "environment" {
  description = "deployment environment"

  validation {
    error_message = "Environment must be local, dev, staging or prod."
    condition = contains(
      ["local", "dev", "staging", "prod"],
      var.environment
    )
  }
}

variable "region_short" {
  description = "GCP region abbreviation/token"
  type        = string
}

variable "instance_id" {
  description = "unique alphanumeric index identifier for resource uniqueness (e.g 001)"
  type        = string
}

# ============================== ==============================
# NAMING INPUTS — keys only, never the full schema.
# This is what keeps common "dumb": it knows a VPC/subnet/workload
# exists and needs a name, never what it's for.
# ============================== ==============================

variable "vpc_subnet_keys" {
  description = "Map of VPC key to its list of subnet keys, derived from var.vpcs in the environment. Used to generate a name for every VPC/subnet without common needing the network schema."
  type        = map(list(string))
  default     = {}
}

variable "workload_keys" {
  description = "List of workload keys, derived from var.workloads in the environment. Used to generate per-workload resource names without common needing the workload schema."
  type        = list(string)
  default     = []
}

variable "artifact_registry_keys" {
  description = "List of artifact registry keys to generate names for."
  type        = list(string)
  default     = []
}

variable "secret_keys" {
  description = "List of secret keys to generate names for."
  type        = list(string)
  default     = []
}

variable "wif_provider_keys" {
  description = "List of workload identity provider keys."
  type        = list(string)
  default     = []
}

variable "cloud_sql_keys" {
  description = "List of cloud sql keys."
  type        = list(string)
  default     = []
}

variable "redis_keys" {
  description = "List of redis keys."
  type        = list(string)
  default     = []
}

variable "filestore_keys" {
  description = "List of filestore keys."
  type        = list(string)
  default     = []
}

variable "edge_backend_keys" {
  description = "List of Edge backend service keys."
  type        = list(string)
  default     = []
}

variable "edge_ssl_keys" {
  description = "List of Edge SSL certificate keys."
  type        = list(string)
  default     = []
}

variable "edge_waf_keys" {
  description = "List of Edge Cloud Armor WAF keys."
  type        = list(string)
  default     = []
}

variable "dashboard_keys" {
  description = "List of Observability Dashboard keys."
  type        = list(string)
  default     = []
}

variable "log_sink_keys" {
  description = "List of Observability Log Sink keys."
  type        = list(string)
  default     = []
}

variable "state_registry_prefix" {
  description = "The GCS prefix used for the cross-repo outputs registry."
  type        = string
}

variable "additional_apis" {
  description = "List of additional APIs to enable for specific stacks."
  type        = list(string)
  default     = []
}

variable "state_bucket_prefix" {
  description = "The state bucket prefix used to construct the bucket name"
  type        = string
}

variable "override_computed_state_bucket_name" {
  type    = string
  default = ""
}
