# MMO FES Core Infrastructure

Infrastructure-as-Code (IaC) for the MMO Fish Export Service (FES) platform. This repository defines, parameterises, and automates provisioning of Azure resources using Bicep templates orchestrated by Azure DevOps pipelines.

## ✅ Scope & Objectives

This repo delivers the repeatable, idempotent deployment of foundational cloud resources that multiple FES workloads consume. Key goals:

- Standardised, secure baseline for application workloads
- Environment consistency
- Separation of concerns
- Automated governance, observability and least‑privilege access enablement

## 🧱 Core Capabilities

| Area                    | Provided Resources / Patterns                                              |
| ----------------------- | -------------------------------------------------------------------------- |
| Networking              | Virtual networks, subnets, private endpoints                               |
| Security / Secrets      | Key Vaults, access policies / RBAC, diagnostic + retention configs         |
| Observability           | Log Analytics Workspace, Application Insights components & dashboards      |
| Data Platform           | Cosmos DB (Mongo API), Redis Cache, Storage Accounts                       |
| Messaging / Integration | Service Bus namespaces/queues/topics, Logic Apps Standard, API Connections |
| Compute Foundation      | App Service Plans, App Services, Function Apps                             |
| Container Supply Chain  | Azure Container Registry                                                   |
| Operational Tooling     | Metric / Activity log alerts, dashboards, tagging & cost governance        |

---

## 📁 Repository Structure

```text
├─ bicepconfig.json                # Bicep configuration (module aliases, analyzers, etc.)
├─ *.yml / *.yaml                  # Pipeline/workflow definitions
├─ templates/                      # Modular Bicep building blocks (one folder per domain)
│  ├─ apiConnections/              # Managed API connection resources + access policies
│  ├─ appInsights/                 # App Insights + dashboards
│  ├─ appServicePlan/              # App Service Plan definitions
│  ├─ connectionStrings/           # Centralised connection string outputs/refs
│  ├─ containerRegistries/         # Azure Container Registry
│  ├─ cosmosDB/                    # Cosmos DB accounts
│  ├─ event/                       # Event Hubs
│  ├─ functionApps/                # Function Apps
│  ├─ keyVaults/                   # Key Vault instance
│  ├─ logAnalytics/                # Log Analytics Workspace
│  ├─ logicAppsStandard/           # Logic App Standard hosting & connectors config
│  ├─ monitoring/                  # Metric + activity alerts, dashboards
│  ├─ network/                     # VNet, subnets
│  ├─ redisCache/                  # Azure Cache for Redis instances
│  ├─ serviceBus/                  # Service Bus namespaces, queues, topics
│  ├─ storageAccounts/             # General purpose storage (blob/queue/file/table)
│  └─ webApps/                     # Web app infra (slots, settings scaffolding)
```

### Module Conventions

- Each module folder: `*.bicep` (resource composition) + matching `*.bicepparam` (environment parameters)
- Some of the modules have bicepparams that are compiled to `*.parameters.json`. This is to enable proper validation in CI pipeline when the variables with json content are being replaced on the bicepparam files. Compiling it in the source code helps to overcome this validation issue.
- Naming & tagging centralised via parameters and/or parent orchestration templates
- Outputs intentionally expose connection endpoints, identities, and keys (never commit secret values)
- Role assignment modules split out (e.g. `acrRoleAssignments`) for principle-of-least-change

---

## 🧪 Parameters & Configuration

| Artifact           | Purpose                                                                    |
| ------------------ | -------------------------------------------------------------------------- |
| `bicepconfig.json` | Enables module aliasing, analyzers, and consistent formatting              |
| `*.bicepparam`     | Environment-specific parameterisation; pass into deployment pipeline stage |

Recommendation: keep environment default values minimal; enforce secrets via Key Vault references or pipeline variable groups.

---

## 🚀 Pipeline Catalogue

Below are the infrastructure pipelines defined at repo root. Each section includes placeholders for you to refine with business context & any environment promotion rules.

| File                         | Purpose (High-Level)                                                 |
| ---------------------------- | -------------------------------------------------------------------- |
| `infra-deploy.yml`           | Primary core infra deployment - baseline services in primary region  |
| `infra-deploy-secondary.yml` | Secondary region deployment / DR parity                              |
| `infra-ephemeral-delete.yml` | Automated teardown of ephemeral environment resources                |
| `ssv5-ephemeral-delete.yml`  | Teardown specific to SSV5 ephemeral stack                            |
| `deploy-ref-files.yaml`      | Upload / sync reference data assets (species, commodity codes, etc.) |
| `create-alerts.yaml`         | Provision / update alert rules (metric & activity)                   |
| `Import-Workflow.yml`        | Import Logic App Standard workflows (deployment automation)          |
| `ccoe-ssv5-deploy.yml`       | SSV5 deployment pipeline                                             |

### 1. `infra-deploy.yml`

Primary region infrastructure deployment. Supports deploying ALL or a selected subset of modules (modular/matrix approach) so teams can:

- Deploy everything (fresh environment bootstrap)
- Deploy grouped domains (e.g. `Apps - All` to roll out all web/function app related components together)
- Deploy individual foundational pieces (e.g. only `network`, only `serviceBus`)

Key Characteristics:

- Region: Primary (e.g. `uksouth` unless changed by parameter)
- Idempotent Bicep module orchestration
- Selection implemented via pipeline parameters / conditional template expansion
- Ensures naming/tagging standards and diagnostic settings applied consistently
- Designed to be safe for partial re-runs (no destructive deletes by default)

Usage Scenarios:

- Initial environment provisioning
- Incremental addition of new shared services
- Rolling upgrades of specific domains without touching others

### 2. `infra-deploy-secondary.yml`

Secondary region deployment enabling disaster recovery and regional failover posture.

Key Responsibilities:

- Deploys the same (or approved subset of) infra modules into a secondary region
- Recreates / rebinds Private Endpoints so traffic can route via secondary region network surfaces
- Validates multi-region capable services (Cosmos DB, Redis Cache) are configured for failover / geo-redundancy
- Ensures replicated naming with region discriminator suffix/pattern

Operational Notes:

- Should be run after primary baseline exists
- Supports targeted domain deployment similar to primary pipeline

DR / Failover Considerations:

- Cosmos DB: multi-region write/read settings (failover priority outside pipeline scope but documented)
- Redis: Geo-replication / link validation
- Private DNS Zones: ensure secondary linkage for PE resolution

### 3. `infra-ephemeral-delete.yml`

Automated cleanup for EPHEMERAL environments (short-lived sandboxes) removing compute/platform resources while persisting essential artifacts.

Purpose:

- Reduce cost by tearing down App Services, App Service Plans, Logic Apps, and related ephemeral components when not in active use
- Export Logic App Standard workflows prior to removal so state/config can be re-imported later

Key Behaviour:

- Trigger: Scheduled CRON (Mon–Fri 19:30 UTC) – `cron: "30 19 * * 1-5"`
- Conditional execution on `ephemeral` variable flag (prevents accidental deletion of persistent resources)
- Ordered steps (based on current YAML):
  1. Export Reference Logic App workflows
  2. Export Processor Logic App workflows
  3. Remove Logic App access policies
  4. Remove Key Vault role assignments (secrets user access)
  5. Remove Storage Account role assignments (Contributor, Blob Data Contributor, Table Data Contributor)
  6. Remove Service Bus role assignments (Data Receiver, Data Sender)
  7. Remove residual ephemeral resources (final sweep)

Safeguards / Recommendations:

- Use tagging model (`Ephemeral=true`) to scope eligible resources

Outputs / Artifacts:

- Workflow definition files in designated storage account

### 4. `ssv5-ephemeral-delete.yml`

Specialised ephemeral teardown for SSV5 context focusing on SSV5 subscription nuances.

Purpose:

- Remove role assignments for ephemeral SSV5-scoped resources
- Retag Docker images currently deployed so they can be traced / reused (avoids orphaned images)

Key Behaviour:

- Scheduled CRON (timing aligns with cost optimisation window – exact cron defined in that YAML)
- Focus on RBAC cleanup to enforce least privilege after environment disposal
- Image retagging ensures latest deployed versions remain identifiable for rapid reprovisioning

### 5. `deploy-ref-files.yaml`

Deploys curated domain reference data files into storage accounts for application consumption.

Scope:

- Species lists, commodity codes, seasonal data, conversion factors, gear types, RFMO lists, etc.
- Ensures consistent, version-controlled ingestion across environments

Behaviour:

- Uploads only changed files (recommended optimisation – validate hashing)
- Can be re-run safely; overwrites are intentional authoritative updates

Governance:

- Treat repository versions as single source of truth

### 6. `create-alerts.yaml`

Creates / updates Azure Monitor alert rules for core platform workloads (App Services + Logic Apps + supporting services).

Scope / Examples:

- Availability / HTTP 5xx thresholds for Web Apps
- Function execution failures, host instance scale anomalies
- Logic App run failure counts / latency

Design Principles:

- Idempotent: updates existing rules rather than duplicating
- Uses shared Action Groups

### 7. `Import-Workflow.yml`

Re-imports previously exported Logic App Standard workflows after ephemeral teardown or environment rebuild.

Key Behaviour:

- Scheduled (CRON) to run post-provisioning window (exact schedule defined in YAML) OR triggered manually after infra redeploy
- Pulls exported definitions from storage account artifact container
- Imports sequentially ensuring dependency ordering (if any connectors prerequisites required)

Safeguards:

- Idempotent: existing workflow replaced/updated rather than duplicated
- Validation step can confirm workflow count matches export manifest

### 8. `ccoe-ssv5-deploy.yml`

Deploys SSV5 subscription-specific core resources under CCoE (Cloud Centre of Excellence) governance.

Scope:

- Network baseline (VNets, subnets, private DNS linkage)
- Azure Container Registry (primary + replication / PE as required)
- Role assignments

---

## 🔄 Typical Deployment Flow

1. Commit / PR modifies one or more Bicep modules or parameter files.
2. CI validation ensures syntactic + semantic correctness.
3. Manual or automated approval gates (per environment) – policy & security review.

---

## 🛡️ Security & Governance Practices

- Private Endpoints preferentially used
- Key Vault: no secrets committed
- Role based access control with system-assigned managed identities.
- Tagging baseline
- Diagnostic settings: all PaaS resources forward to centralized Log Analytics

---

## 🧪 Testing Strategy (Infra)

| Level   | Approach                                  |
| ------- | ----------------------------------------- |
| Lint    | Bicep analyzers & `bicep build` in CI     |
| Preview | `az deployment what-if` for change impact |

---

## 🧩 Adding / Modifying a Module

1. Create new folder under `templates/yourModuleName`.
2. Author `yourModuleName.bicep` and (optionally) `yourModuleName.bicepparam`.
3. Re-use existing naming, tagging and diagnostic modules where possible.
4. Run local `bicep build` to validate syntax.
5. Open PR including design notes if resource count or cost impact is material.
6. Ensure outputs necessary for downstream modules are explicit.

---

## 🗂️ Reference Data Synchronisation

Handled via `deploy-ref-files.yaml` pipeline which pushes curated CSV / JSON to a storage container for application consumption (e.g. species lists, commodity codes).

---

## 🤝 Contributing

- Create a feature branch: `feature/<short-description>`
- Keep changes modular – one domain folder per PR where feasible
- Update parameter files consistently across environments
- Add/Update placeholders or docs if altering pipeline logic
- Request security + cost review for high-impact resources (e.g., new SKU tiers)

---

## 🔧 Tooling Prerequisites (Local Authoring)

- Azure CLI (latest)
- Logged into correct subscription + tenant (`az account show`)
- (Optional) PSRule for Azure / ARM Analyzer for policy alignment

---
