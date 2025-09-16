# MDC ↔ GCP Multi‑Project Starter

Tiny repo to onboard Google Cloud projects to **Microsoft Defender for Cloud (MDC)** using **Workload Identity Federation (WIF)**.

Two patterns are included:

- **Org-level pool (recommended for many projects):**
  - Create one WIF **pool + OIDC provider(s)** at the **organization**.
  - Onboard each project by creating a **service account**, binding **least‑privilege** roles, and granting **workloadIdentityUser** to the org pool.
- **Project-scoped pool (per project):**
  - Create a WIF **pool + provider(s)** in **each project**.
  - Onboard the project to its own pool.

> **Where to run**: All scripts are designed for **GCP Cloud Shell**. Ensure your account has the required IAM permissions noted at the top of each script.

## Quick start (org-level recommended)

1. **Run once per org** (creates org-level pool + CSPM provider):  
   ```bash
   ./org/org-wif-pool-and-cspm-provider.sh
   ```

2. *(Optional)* **Add Defender for Servers provider** (once per org):  
   ```bash
   ./org/org-servers-provider.sh
   ```

3. **Per GCP project** (CSPM):  
   ```bash
   ./project/project-onboard-cspm-to-org-pool.sh
   ```

4. *(Optional)* **Per GCP project** (Defender for Servers):  
   ```bash
   ./project/project-onboard-servers-to-org-pool.sh
   ```

5. **Azure step:** Open **Azure Portal → Defender for Cloud → Environment settings → Add environment → GCP** and use the wizard to **validate** each project connector.

## Files

- `org/org-wif-pool-and-cspm-provider.sh` – Org-level **pool + CSPM** provider (run once).
- `org/org-servers-provider.sh` – Org-level **Servers** provider (run once).
- `project/project-onboard-cspm-to-org-pool.sh` – Per-project **CSPM** onboarding to org pool.
- `project/project-onboard-servers-to-org-pool.sh` – Per-project **Servers** onboarding to org pool.
- `project/project-pool-cspm-provider.sh` – Project-level **CSPM** provider (only if using project-scoped pools).
- `project/project-onboard-servers-to-project-pool.sh` – Project-level **Servers** onboarding (only if using project-scoped pools).

> Each script is **idempotent** and safe to re-run. Fill in placeholders at the top of each file.

## Author / Date 
  Author: Anthony Fuller  
  Date:   2025-09-19

