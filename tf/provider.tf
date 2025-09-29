#
# "provider.tf"
#
# Specifies the provider for this project.
#

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google-beta"
      version = ">= 4.0.0"
    }
  }
  backend "gcs" {
    bucket  = "propaghandi_state"
    prefix  = "terraform/state"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}
