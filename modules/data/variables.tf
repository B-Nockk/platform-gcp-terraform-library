# terraform/modules/data/variables.tf

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "resource_computed_names" {
  type = any
}

variable "network_self_links" {
  description = "Map of VPC self links for private connectivity"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# Data Driven Configurations (Null Toggles)
# ------------------------------------------------------------------------------

variable "cloud_sql" {
  description = "Optional map of Cloud SQL Postgres instances to create."
  type = map(object({
    tier              = string
    database_version  = string
    vpc_key           = string
    availability_type = string # REGIONAL or ZONAL
  }))
  default = {}
}

variable "redis" {
  description = "Optional map of Memorystore Redis instances to create."
  type = map(object({
    tier           = string
    memory_size_gb = number
    vpc_key        = string
  }))
  default = {}
}

variable "filestore" {
  description = "Optional map of Filestore instances to create."
  type = map(object({
    tier        = string
    capacity_gb = number
    vpc_key     = string
    file_shares = list(object({
      name = string
    }))
  }))
  default = {}
}
