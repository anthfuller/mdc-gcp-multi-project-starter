#!/usr/bin/env bash
# =============================================================================
# Per-project onboarding to ORG-level pool for CSPM
# WHERE TO RUN: GCP Cloud Shell
# REQUIRED (project): roles/resourcemanager.projectIamAdmin, roles/iam.serviceAccountAdmin
# OPTIONAL (if enabling APIs): roles/serviceusage.serviceUsageAdmin
#
# Author: Anthony Fuller
# Date:   2025-09-19
# =============================================================================
set -euo pipefail

# --- EDIT ---
PROJECT_ID="<YOUR_GCP_PROJECT_ID>"
ORG_NUMBER="<YOUR_ORG_NUMBER>"
POOL_ID="mdc-wi-pool"                    # must match org script
CSPM_SA_NAME="microsoft-defender-cspm"
USE_CUSTOM_ROLE="true"                   # set to "false" to use roles/viewer
CSPM_ROLE_ID="MDCCspmCustomRole"

gcloud config set project "${PROJECT_ID}"
PROJECT_NUMBER="$(gcloud projects describe "${PROJECT_ID}" --format='value(projectNumber)')"
CSPM_SA_EMAIL="${CSPM_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Optional APIs (safe to re-run)
# gcloud services enable iam.googleapis.com iamcredentials.googleapis.com sts.googleapis.com #   cloudresourcemanager.googleapis.com serviceusage.googleapis.com #   compute.googleapis.com apikeys.googleapis.com osconfig.googleapis.com --project "${PROJECT_ID}"

# Service Account
if gcloud iam service-accounts describe "${CSPM_SA_EMAIL}" --project "${PROJECT_ID}" >/dev/null 2>&1; then
  gcloud iam service-accounts update "${CSPM_SA_EMAIL}" --display-name="Microsoft Defender CSPM" --project "${PROJECT_ID}"
else
  gcloud iam service-accounts create "${CSPM_SA_NAME}" --display-name="Microsoft Defender CSPM" --project "${PROJECT_ID}"
fi

# Custom role (optional)
if [[ "${USE_CUSTOM_ROLE}" == "true" ]]; then
  ROLE_PERMS="resourcemanager.projects.get,serviceusage.services.list,compute.instances.list,compute.disks.list,compute.networks.list,compute.subnetworks.list,storage.buckets.list,storage.buckets.getIamPolicy,iam.serviceAccounts.list,iam.serviceAccounts.getIamPolicy,iam.serviceAccountKeys.list,iam.roles.list,iam.roles.get,logging.logMetrics.list,logging.sinks.list,logging.logEntries.list,monitoring.alertPolicies.list,container.clusters.list"
  if gcloud iam roles describe "${CSPM_ROLE_ID}" --project "${PROJECT_ID}" >/dev/null 2>&1; then
    gcloud iam roles update "${CSPM_ROLE_ID}" --project "${PROJECT_ID}" --title="${CSPM_ROLE_ID}" --description="MDC CSPM custom role" --permissions="${ROLE_PERMS}"
  else
    gcloud iam roles create "${CSPM_ROLE_ID}" --project "${PROJECT_ID}" --title="${CSPM_ROLE_ID}" --description="MDC CSPM custom role" --permissions="${ROLE_PERMS}"
  fi
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" --member="serviceAccount:${CSPM_SA_EMAIL}" --role="projects/${PROJECT_ID}/roles/${CSPM_ROLE_ID}"
else
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" --member="serviceAccount:${CSPM_SA_EMAIL}" --role="roles/viewer"
fi

# Allow org pool to impersonate this SA
gcloud iam service-accounts add-iam-policy-binding "${CSPM_SA_EMAIL}"   --project "${PROJECT_ID}" --role="roles/iam.workloadIdentityUser"   --member="principalSet://iam.googleapis.com/organizations/${ORG_NUMBER}/locations/global/workloadIdentityPools/${POOL_ID}/*"

echo "Project '${PROJECT_ID}' onboarded to org-level pool '${POOL_ID}' for CSPM."
