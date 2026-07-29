# terraform/modules/common/resource_computed_names.tf

locals {
  resource_computed_names = {
    # Conceptually the "Resource Group", but named for GCP reality
    project_id = var.project_id

    # Dynamic across ANY number of VPCs/subnets — no more hardcoded "primary".
    # Both the VPC key and the subnet key are folded into every name, so two
    # VPCs each with a "public_subnet" can never collide.
    vpcs = {
      for vpc_key, subnet_keys in var.vpc_subnet_keys : vpc_key => {
        name = join(local.sep.hyphen, [
          local.resource_type_token.vpc, vpc_key, local.resource_identifier
        ])

        subnets = {
          for subnet_key in subnet_keys : subnet_key => join(local.sep.hyphen, [
            local.resource_type_token.subnet, vpc_key, subnet_key, local.resource_identifier
          ])
        }

        # Prefixes for dynamic resources (firewalls/routes) — the vpc module
        # appends its own rule/route key to these. This is the only place
        # that prefix is ever built.
        firewall_prefix = join(local.sep.hyphen, [
          local.resource_type_token.firewall_rule, vpc_key, local.resource_identifier
        ])

        route_prefix = join(local.sep.hyphen, [
          local.resource_type_token.route, vpc_key, local.resource_identifier
        ])
      }
    }

    # Every name a workload could need — service account, instance template,
    # instance group, health check, and the VM base-name prefix. One place,
    # so iam/compute never invent a naming fragment of their own again.
    workloads = {
      for key in var.workload_keys : key => {
        service_account   = join(local.sep.hyphen, [local.resource_type_token.service_account, key, local.resource_identifier])
        instance_prefix   = join(local.sep.hyphen, [local.resource_type_token.compute_instance, key, local.resource_identifier])
        instance_template = join(local.sep.hyphen, [local.resource_type_token.instance_template, key, local.resource_identifier])
        instance_group    = join(local.sep.hyphen, [local.resource_type_token.managed_instance_group, key, local.resource_identifier])
        health_check      = join(local.sep.hyphen, [local.resource_type_token.health_check, key, local.resource_identifier])
      }
    }

    artifact_registries = {
      for key in var.artifact_registry_keys : key => join(local.sep.hyphen, [local.resource_type_token.artifact_registry, key, local.resource_identifier])
    }

    secrets = {
      for key in var.secret_keys : key => join(local.sep.hyphen, [local.resource_type_token.secret_manager, key, local.resource_identifier])
    }

    workload_identity_pool = join(local.sep.hyphen, [local.resource_type_token.workload_identity_pool, local.resource_identifier])

    workload_identity_providers = {
      for key in var.wif_provider_keys : key => join(local.sep.hyphen, [local.resource_type_token.workload_identity_provider, key, local.resource_identifier])
    }

    cloud_sql_instances = {
      for key in var.cloud_sql_keys : key => join(local.sep.hyphen, [local.resource_type_token.cloud_sql, key, local.resource_identifier])
    }

    redis_instances = {
      for key in var.redis_keys : key => join(local.sep.hyphen, [local.resource_type_token.memorystore_redis, key, local.resource_identifier])
    }

    filestore_instances = {
      for key in var.filestore_keys : key => join(local.sep.hyphen, [local.resource_type_token.filestore, key, local.resource_identifier])
    }

    edge_backends = {
      for key in var.edge_backend_keys : key => join(local.sep.hyphen, [local.resource_type_token.backend_service, key, local.resource_identifier])
    }

    edge_ssl_certs = {
      for key in var.edge_ssl_keys : key => join(local.sep.hyphen, [local.resource_type_token.ssl_certificate, key, local.resource_identifier])
    }

    edge_waf_policies = {
      for key in var.edge_waf_keys : key => join(local.sep.hyphen, [local.resource_type_token.security_policy, key, local.resource_identifier])
    }

    # Load Balancer Components (usually singular per stack, but we can parameterize or use simple prefix)
    edge_lb = {
      forwarding_rule = join(local.sep.hyphen, [local.resource_type_token.forwarding_rule, local.resource_identifier])
      target_proxy    = join(local.sep.hyphen, [local.resource_type_token.target_proxy, local.resource_identifier])
      url_map         = join(local.sep.hyphen, [local.resource_type_token.url_map, local.resource_identifier])
    }

    dashboards = {
      for key in var.dashboard_keys : key => join(local.sep.hyphen, [local.resource_type_token.monitoring_dashboard, key, local.resource_identifier])
    }

    log_sinks = {
      for key in var.log_sink_keys : key => join(local.sep.hyphen, [local.resource_type_token.log_sink, key, local.resource_identifier])
    }

    # Cross-Repo Registry Path
    # Generates: "registry/dev/v1/outputs.json"
    state_outputs_registry_path = join(local.sep.slash, [
      var.state_registry_prefix,
      var.environment,
      "v1",
      "outputs.json"
    ])
  }

  computed_state_bucket_name = join(local.sep.hyphen, [
    var.state_bucket_prefix,
    var.project_id
  ])

  final_state_bucket_name = var.override_computed_state_bucket_name != "" ? var.override_computed_state_bucket_name : local.computed_state_bucket_name
}
