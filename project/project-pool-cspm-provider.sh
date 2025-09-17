#!/usr/bin/env bash
# Purpose: Create a project-scoped Workload Identity Federation pool and OIDC provider for CSPM onboarding.
# =============================================================================
# Project-level WIF CSPM provider (only if using project-scoped pools)
# WHERE TO RUN: GCP Cloud Shell
# REQUIRED (project): roles/iam.workloadIdentityPoolAdmin
#
# Author: Anthony Fuller
# Date:   2025-09-19
# =============================================================================
set -euo pipefail

# --- EDIT ---
PROJECT_ID="<YOUR_GCP_PROJECT_ID>"
POOL_ID="mdc-wi-pool"
CSPM_PROVIDER_ID="cspm"
AZURE_TENANT_ID="<YOUR_AZURE_TENANT_ID>"
CSPM_ALLOWED_AUDIENCE="<YOUR_MDC_APP_AUDIENCE_URI>"

gcloud config set project "${PROJECT_ID}"
ISSUER_URI="https://sts.windows.net/${AZURE_TENANT_ID}"

if gcloud iam workload-identity-pools providers describe "${CSPM_PROVIDER_ID}"    --location=global --workload-identity-pool="${POOL_ID}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
  gcloud iam workload-identity-pools providers update-oidc "${CSPM_PROVIDER_ID}"     --location=global --workload-identity-pool="${POOL_ID}" --project="${PROJECT_ID}"     --issuer-uri="${ISSUER_URI}"     --allowed-audiences="${CSPM_ALLOWED_AUDIENCE}"     --attribute-mapping="google.subject=assertion.sub"
else
  gcloud iam workload-identity-pools providers create-oidc "${CSPM_PROVIDER_ID}"     --location=global --workload-identity-pool="${POOL_ID}" --project="${PROJECT_ID}"     --issuer-uri="${ISSUER_URI}"     --allowed-audiences="${CSPM_ALLOWED_AUDIENCE}"     --attribute-mapping="google.subject=assertion.sub"
fi

echo "Project-level CSPM provider '${CSPM_PROVIDER_ID}' is ready under pool '${POOL_ID}'."
