#
# "main.tf"
#
# Defines the resources for this project.
#
resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_project_service" "secret_manager_api" {
  project = var.gcp_project_id
  service = "secretmanager.googleapis.com"

  # This prevents Terraform from disabling the API when you run `terraform destroy`.
  # It's a best practice to set this to false for most API enablement.
  disable_on_destroy = false
}

resource "google_storage_bucket" "posts_bucket" {
  project                     = var.gcp_project_id
  name                        = "${random_id.bucket_prefix.hex}-bucket"
  location                    = var.gcp_region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_service_account" "innoreader_handler_sa" {
  project      = var.gcp_project_id
  account_id   = "innoreader-handler-sa"
  display_name = "Innoreader Handler Service Account"
}

resource "google_storage_bucket_iam_member" "innoreader_handler_sa" {
  bucket = google_storage_bucket.posts_bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.innoreader_handler_sa.email}"
}

resource "google_service_account" "innoreader_handler_gateway_sa" {
  project      = var.gcp_project_id
  account_id   = "innoreader-handler-gateway-sa"
  display_name = "API Gateway service account"
}

resource "google_project_iam_member" "innoreader_handler_gateway_cloudfunctions_invoker" {
  project = var.gcp_project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.innoreader_handler_gateway_sa.email}"
}

# API Gateway
resource "google_api_gateway_gateway" "innoreader_handler" {
  project  = var.gcp_project_id
  region   = var.gcp_region_gateway
  gateway_id = "innoreader-handler"
  api_config = google_api_gateway_api_config.innoreader_handler.id
}

resource "google_api_gateway_api" "innoreader_handler" {
  project = var.gcp_project_id
  api_id   = "innoreader-handler"
}

resource "google_api_gateway_api_config" "innoreader_handler" {
  project      = var.gcp_project_id
  api          = google_api_gateway_api.innoreader_handler.api_id
  api_config_id = "innoreader-handler"

  openapi_documents {
    document {
      path     = "spec.yaml"
      contents = filebase64("spec.yaml")
    }
  }

  gateway_config {
    backend_config {
      google_service_account = google_service_account.innoreader_handler_gateway_sa.id
    }
  }
}
