#
# "secrets.tf"
#
# Contains all the secrets for this project.
#



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
