# terraform/modules/project-services/main.tf

variable "project_id" { type = string }
variable "required_apis" { type = list(string) }

resource "google_project_service" "this" {
  for_each = toset(var.required_apis)

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false # Fails fast without breaking the project on teardown
}

# GCP APIs often take 10-30 seconds to be fully usable by downstream resources after they are enabled.
resource "time_sleep" "wait_for_apis" {
  create_duration = var.enable_services_wait_time
  depends_on      = [google_project_service.this]
}
