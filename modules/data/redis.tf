# terraform/modules/data/redis.tf

# ------------------------------------------------------------------------------
# Memorystore Redis
# ------------------------------------------------------------------------------

resource "google_redis_instance" "this" {
  for_each = var.redis

  name               = var.resource_computed_names.redis_instances[each.key]
  project            = var.project_id
  region             = var.region
  tier               = each.value.tier
  memory_size_gb     = each.value.memory_size_gb
  authorized_network = var.network_self_links[each.value.vpc_key]

  labels = var.common_tags
}
