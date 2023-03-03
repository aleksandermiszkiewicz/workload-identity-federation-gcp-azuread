data "google_project" "project" {
  project_id = var.project_id
}

# enabling required GCP APIs
resource "google_project_service" "enable_iam_api" {
  project = var.project_id
  service = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "enable_resource_manager_api" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "enable_iam_credentials_api" {
  project = var.project_id
  service = "iamcredentials.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "enable_sts_api" {
  project = var.project_id
  service = "sts.googleapis.com"
  disable_on_destroy = false
}

# workload identity pool creation
resource "google_iam_workload_identity_pool" "workload_identity_pool" {
  project                   = var.project_id
  workload_identity_pool_id = var.workload_identity_pool_name
  display_name              = var.workload_identity_pool_display_name
  description               = var.workload_identity_pool_description
  disabled                  = false
}

# workload identity pool provider
resource "google_iam_workload_identity_pool_provider" "workload_identity_pool_provider" {
  project                            = var.project_id
  workload_identity_pool_id          = var.workload_identity_pool_name
  workload_identity_pool_provider_id = var.workload_identity_pool_provider_id
  display_name                       = var.workload_identity_pool_provider_id
  description                        = var.workload_identity_pool_provider_description
  disabled                           = false
  attribute_mapping                  = var.workload_identity_pool_provider_attribute_mappings

  oidc {
    allowed_audiences = var.workload_identity_pool_provider_allowed_audiences
    issuer_uri        = "https://sts.windows.net/${var.azure_tenant_id}"
  }

  depends_on = [google_iam_workload_identity_pool.workload_identity_pool]
}