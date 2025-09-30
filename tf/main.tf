#
# "main.tf"
#
# Defines the resources for this project.
#
resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "posts_bucket" {
  project                     = var.gcp_project_id
  name                        = "${random_id.bucket_prefix.hex}-bucket"
  location                    = var.gcp_region
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_service_account" "cloud_build_sa" {
  project      = var.gcp_project_id
  account_id   = "cloud-build-sa"
  display_name = "Cloud Build Service Account"
}

resource "google_service_account" "innoreader_handler_sa" {
  project      = var.gcp_project_id
  account_id   = "innoreader-handler-sa"
  display_name = "Innoreader Handler Service Account"
}

resource "google_project_iam_member" "cloud_build_sa_cloudfunctions_admin" {
  project = var.gcp_project_id
  role    = "roles/cloudfunctions.admin"
  member  = "serviceAccount:${google_service_account.cloud_build_sa.email}"
}

resource "google_project_iam_member" "cloud_build_sa_cloudbuild_builds_editor" {
  project = var.gcp_project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:${google_service_account.cloud_build_sa.email}"
}

resource "google_service_account_iam_member" "cloud_build_sa" {
  service_account_id = google_service_account.innoreader_handler_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.cloud_build_sa.email}"
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


resource "google_secret_manager_secret" "innoreader_handler_sa_email" {
  secret_id = "innoreader_handler_sa_email"
  project   = var.gcp_project_id
  replication {
    auto {
      }
    }
}

resource "google_secret_manager_secret_version" "innoreader_handler_sa_email" {
  secret      = google_secret_manager_secret.innoreader_handler_sa_email.id
  secret_data = google_service_account.innoreader_handler_sa.email
}

resource "google_secret_manager_secret" "randomdatahandler_sa_email" {
  secret_id = "randomdatahandler_sa_email"
  project   = var.gcp_project_id
  replication {
    auto {
      }
    }
}

resource "google_secret_manager_secret" "innoreader_handler_gateway_sa_email" {
  secret_id = "innoreader_handler_gateway_sa_email"
  project   = var.gcp_project_id
  replication {
    auto {
      }
    }
}

resource "google_secret_manager_secret_version" "innoreader_handler_gateway_sa_email" {
  secret      = google_secret_manager_secret.innoreader_handler_gateway_sa_email.id
  secret_data = google_service_account.innoreader_handler_gateway_sa.email
}

resource "google_secret_manager_secret" "posts_bucket_name" {
  secret_id = "posts_bucket_name"
  project   = var.gcp_project_id
  replication {
    auto {
      }
    }
}

resource "google_secret_manager_secret_version" "posts_bucket_name" {
  secret      = google_secret_manager_secret.posts_bucket_name.id
  secret_data = google_storage_bucket.posts_bucket.name
}

resource "google_secret_manager_secret" "innoreader_handler_gateway_url" {
  secret_id = "innoreader_handler_gateway_url"
  project   = var.gcp_project_id
  replication {
    auto {
      }
    }
}

resource "google_secret_manager_secret_version" "innoreader_handler_gateway_url" {
  secret      = google_secret_manager_secret.innoreader_handler_gateway_url.id
  secret_data = google_api_gateway_gateway.innoreader_handler.default_hostname
}

resource "google_apikeys_key" "innoreader-handler" {
  name         = "innoreader-handler-api-key"
  display_name = "innoreader-handler-key"
}

resource "google_secret_manager_secret" "innoreader-handler-api-key" {
  secret_id = "innoreader-handler-api-key"
  project   = var.gcp_project_id
  replication {
    auto {
      }
    }
}

resource "google_secret_manager_secret_version" "innoreader-handler-api-key" {
  secret      = google_secret_manager_secret.innoreader-handler-api-key.id
  secret_data = google_apikeys_key.innoreader-handler.key_string
}