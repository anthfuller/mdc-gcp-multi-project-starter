#!/usr/bin/env bash
# =============================================================================
# Per-project onboarding to PROJECT-level pool for Defender for Servers
# WHERE TO RUN: GCP Cloud Shell
# REQUIRED (project): roles/resourcemanager.projectIamAdmin, roles/iam.serviceAccountAdmin
#
# Author: Anthony Fuller
# Date:   2025-09-19
# =============================================================================
set -euo pipefail

# --- EDIT ---
PROJECT_ID="<YOUR_GCP_PROJECT_ID>"
POOL_ID="mdc-wi-pool"
SERVERS_SA_NAME="microsoft-defender-for-servers"

# Optional APIs
# gcloud services enable compute.googleapis.com osconfig.googleapis.com --project "${PROJECT_ID}"

gcloud config set project "${PROJECT_ID}"
PROJECT_NUMBER="$(gcloud projects describe "${PROJECT_ID}" --format='value(projectNumber)')"
SERVERS_SA_EMAIL="${SERVERS_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# SA (idempotent)
if gcloud iam service-accounts describe "${SERVERS_SA_EMAIL}" --project "${PROJECT_ID}" >/dev/null 2>&1; then
  gcloud iam service-accounts update "${SERVERS_SA_EMAIL}" --display-name="Microsoft Defender for Servers" --project "${PROJECT_ID}"
else
  gcloud iam service-accounts create "${SERVERS_SA_NAME}" --display-name="Microsoft Defender for Servers" --project "${PROJECT_ID}"
fi

# Minimal roles
gcloud projects add-iam-policy-binding "${PROJECT_ID}" --member="serviceAccount:${SERVERS_SA_EMAIL}" --role="roles/compute.viewer"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" --member="serviceAccount:${SERVERS_SA_EMAIL}" --role="roles/osconfig.osPolicyAssignmentAdmin"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" --member="serviceAccount:${SERVERS_SA_EMAIL}" --role="roles/osconfig.osPolicyAssignmentReportViewer"

# Allow project-level pool to impersonate this SA
gcloud iam service-accounts add-iam-policy-binding "${SERVERS_SA_EMAIL}"   --project="${PROJECT_ID}" --role="roles/iam.workloadIdentityUser"   --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_ID}/*"

echo "Project '${PROJECT_ID}' is ready for Defender for Servers via project pool '${POOL_ID}'."
