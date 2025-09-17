#!/usr/bin/env bash
# Purpose: Create an organization-level Workload Identity Federation pool and OIDC provider for onboarding GCP projects to Microsoft Defender for Cloud (CSPM).
# =============================================================================
# Org-level WIF pool + CSPM provider (run ONCE per org)
# WHERE TO RUN: GCP Cloud Shell (https://shell.cloud.google.com)
# REQUIRED (org): roles/iam.workloadIdentityPoolAdmin
#
# Author: Anthony Fuller
# Date:   2025-09-19
# =============================================================================
set -euo pipefail

# --- EDIT ---
ORG_NUMBER="<YOUR_ORG_NUMBER>"                              # e.g., 123456789012
POOL_ID="mdc-wi-pool"                                       # shared across projects
CSPM_PROVIDER_ID="cspm"                                     # provider ID in the pool
AZURE_TENANT_ID="<YOUR_AZURE_TENANT_ID>"                    # e.g., 33e01921-...
CSPM_ALLOWED_AUDIENCE="<YOUR_MDC_APP_AUDIENCE_URI>"         # e.g., api://6e81e733-...

ISSUER_URI="https://sts.windows.net/${AZURE_TENANT_ID}"

# Create/Update WIF Pool at org
if gcloud iam workload-identity-pools describe "${POOL_ID}" --location=global --organization="${ORG_NUMBER}" >/dev/null 2>&1; then
  gcloud iam workload-identity-pools update "${POOL_ID}"     --location=global --organization="${ORG_NUMBER}"     --display-name="Microsoft Defender for Cloud (Org Pool)"     --description="Shared WIF pool for MDC across org projects"
else
  gcloud iam workload-identity-pools create "${POOL_ID}"     --location=global --organization="${ORG_NUMBER}"     --display-name="Microsoft Defender for Cloud (Org Pool)"     --description="Shared WIF pool for MDC across org projects"
fi

# Create/Update CSPM provider
if gcloud iam workload-identity-pools providers describe "${CSPM_PROVIDER_ID}"    --location=global --workload-identity-pool="${POOL_ID}" --organization="${ORG_NUMBER}" >/dev/null 2>&1; then
  gcloud iam workload-identity-pools providers update-oidc "${CSPM_PROVIDER_ID}"     --location=global --workload-identity-pool="${POOL_ID}" --organization="${ORG_NUMBER}"     --issuer-uri="${ISSUER_URI}"     --allowed-audiences="${CSPM_ALLOWED_AUDIENCE}"     --attribute-mapping="google.subject=assertion.sub"
else
  gcloud iam workload-identity-pools providers create-oidc "${CSPM_PROVIDER_ID}"     --location=global --workload-identity-pool="${POOL_ID}" --organization="${ORG_NUMBER}"     --issuer-uri="${ISSUER_URI}"     --allowed-audiences="${CSPM_ALLOWED_AUDIENCE}"     --attribute-mapping="google.subject=assertion.sub"
fi

echo "Org-level pool '${POOL_ID}' and CSPM provider '${CSPM_PROVIDER_ID}' are ready at organization ${ORG_NUMBER}."
