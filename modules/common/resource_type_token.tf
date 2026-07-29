# terraform/modules/common/resource_type_token.tf

locals {
  # GCP Resource Type Tokens
  # GCP Naming Constraints to remember:
  # 1. Must be lowercase.
  # 2. Can only contain lowercase letters, numbers, and hyphens (-).
  # 3. Must start with a letter.
  # 4. Max 63 characters for most resources.

  resource_type_token = {

    # --- Core Foundation ---
    project = "proj"
    folder  = "fldr"

    # --- Networking ---
    vpc                 = "vpc"
    subnet              = "snet"
    firewall_rule       = "fw"
    route               = "rt"
    cloud_router        = "rtr"
    cloud_nat           = "nat"
    external_ip_address = "eip"
    internal_ip_address = "iip"

    # --- Identity & Security ---
    service_account            = "sa"
    secret_manager             = "sm"
    workload_identity_pool     = "wifp"
    workload_identity_provider = "wifpr"

    # --- Compute & Storage ---
    compute_instance       = "vm"
    instance_template      = "tmpl"
    managed_instance_group = "mig"
    persistent_disk        = "pd"
    storage_bucket         = "bkt"
    health_check           = "hc"
    filestore              = "fs"

    # --- Databases & Data ---
    cloud_sql         = "sql"
    memorystore_redis = "mem"

    # --- Kubernetes & Containers ---
    gke_cluster       = "gke"
    artifact_registry = "ar"

    # --- Monitoring & Logging ---
    logging_bucket       = "log"
    monitoring_dashboard = "dash"
    alert_policy         = "alt"
    log_sink             = "sink"

    # --- Load Balancing & Edge ---
    load_balancer   = "lb"
    forwarding_rule = "fwd"
    target_proxy    = "tproxy"
    url_map         = "urlmap"
    backend_service = "bes"
    ssl_certificate = "ssl"
    security_policy = "waf"
  }

  # Optional: If you want to keep the prefix logic here instead of in main.tf
  # naming_prefix = join("-", [
  #   var.project_name,
  #   var.environment,
  #   var.region_short
  # ])
}
