#
# "variables.tf"
#
# Contains all the variables for this project.
#

variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID."
  default = "linkster-426414"
}

variable "gcp_region_gateway" {
  type        = string
  description = "The GCP region."
  default     = "europe-west1"
}

variable "gcp_region" {
  type        = string
  description = "The GCP region."
  default     = "europe-west4"
}