# terraform/modules/data/filestore.tf

# ------------------------------------------------------------------------------
# Filestore
# ------------------------------------------------------------------------------

resource "google_filestore_instance" "this" {
  for_each = var.filestore

  name    = var.resource_computed_names.filestore_instances[each.key]
  project = var.project_id
  # Filestore is zonal
  location = "${var.region}-a"
  tier     = each.value.tier

  dynamic "file_shares" {
    for_each = each.value.file_shares
    content {
      capacity_gb = each.value.capacity_gb
      name        = file_shares.value.name
    }
  }

  networks {
    network = var.network_self_links[each.value.vpc_key]
    modes   = ["MODE_IPV4"]
  }

  labels = var.common_tags
}
