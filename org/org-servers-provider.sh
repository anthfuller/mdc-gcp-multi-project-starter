#!/usr/bin/env bash
# Purpose: Create an organization-level Workload Identity Federation provider for onboarding GCP projects to Microsoft Defender for Servers (MDE).
# =============================================================================
# Org-level WIF provider for Defender for Servers (run ONCE per org)
# WHERE TO RUN: GCP Cloud Shell (https://shell.cloud.google.com)
# REQUIRED (org): roles/iam.workloadIdentityPoolAdmin
#
# Author: Anthony Fuller
# Date:   2025-09-19
# =============================================================================
set -euo pipefail

# --- EDIT ---
ORG_NUMBER="<YOUR_ORG_NUMBER>"
POOL_ID="mdc-wi-pool"                          # same pool as CSPM
SERVERS_PROVIDER_ID="defender-for-servers"
AZURE_TENANT_ID="<YOUR_AZURE_TENANT_ID>"
SERVERS_AUDIENCE="api://AzureSecurityCenter.MultiCloud.DefenderForServers"

ISSUER_URI="https://sts.windows.net/${AZURE_TENANT_ID}"

if gcloud iam workload-identity-pools providers describe "${SERVERS_PROVIDER_ID}"    --organization="${ORG_NUMBER}" --location=global --workload-identity-pool="${POOL_ID}" >/dev/null 2>&1; then
  gcloud iam workload-identity-pools providers update-oidc "${SERVERS_PROVIDER_ID}"     --organization="${ORG_NUMBER}" --location=global --workload-identity-pool="${POOL_ID}"     --issuer-uri="${ISSUER_URI}"     --allowed-audiences="${SERVERS_AUDIENCE}"     --attribute-mapping="google.subject=assertion.sub"
else
  gcloud iam workload-identity-pools providers create-oidc "${SERVERS_PROVIDER_ID}"     --organization="${ORG_NUMBER}" --location=global --workload-identity-pool="${POOL_ID}"     --issuer-uri="${ISSUER_URI}"     --allowed-audiences="${SERVERS_AUDIENCE}"     --attribute-mapping="google.subject=assertion.sub"
fi

echo "Org-level Servers provider '${SERVERS_PROVIDER_ID}' is ready under pool '${POOL_ID}'."
