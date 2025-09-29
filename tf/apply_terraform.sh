#!/bin/bash
export PATH="$HOME/.tfenv/bin:$PATH"
cd tf
terraform init
terraform apply -auto-approve -var "gcp_project_id=$GCP_PROJECT_ID" -var "gcp_service_account_email=$GCP_SERVICE_ACCOUNT_EMAIL"
