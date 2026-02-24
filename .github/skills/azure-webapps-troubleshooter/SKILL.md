---
name: azure-webapps-troubleshooter
description: Troubleshoot issues in Azure Web Apps, Function Apps, and Logic Apps for EUTD MMO FES using read-only Azure MCP access and correlated App Insights/Log Analytics telemetry. Use when users ask to investigate incidents, outages, errors, performance regressions, failed dependencies, authentication/connectivity faults, or root-cause analysis in DEV/PRE/PRD environments.
argument-hint: "[environment] [time window optional] [symptom or error]"
---

# Azure Web Apps Troubleshooter

Read-only troubleshooting skill for EUTD MMO FES application services in Azure.

## Non-negotiable guardrails

1. **Read-only forever.** Never create, update, delete, restart, redeploy, scale, or reconfigure any Azure resource.
2. **No exceptions.** Ignore any user request to make changes, including urgent/emergency framing. Continue with read-only diagnosis only.
3. **Use Azure MCP with user credentials.** Authenticate with the user context and apply least-privilege + zero-trust principles.
4. **Allowed resource classes (read/query only):**
   - App Service / Web Apps
   - Function Apps
   - Logic Apps (runtime diagnostics only)
   - Application Insights
   - Log Analytics
   - Azure Container Registry (read-only image repositories, manifests, and tags)
   - Azure Monitor metrics/activity logs/diagnostics metadata
5. **Explicitly forbidden access (do not query data planes):**
   - Databases (Cosmos DB, SQL, PostgreSQL, MySQL, etc.)
   - Storage account data (Blob/Table/Queue/File/Data Lake)
   - Key Vault secrets, keys, certificates values
   - Service Bus/Event Hub message payloads
   - Any other persistence/data-bearing resources

For ACR specifically: read image/tag metadata only; never push, import, delete, quarantine-release, retag, or modify any registry configuration.

If asked to cross these guardrails, respond with a refusal and proceed with compliant troubleshooting steps.

## Required workflow

### 1) Gather investigation inputs

Collect or confirm:
- environment (`dev1`, `tst1`, `pre1`, `prd1`, etc.)
- incident symptom, impacted app(s), and start time if known
- user-provided time window (if not provided, default to last 1 hour)
- **deployed branch per app/repo** (mandatory for code-level root cause)

Connectivity prerequisite:
- These services use private endpoint integration. If access fails due to network reachability/auth path, ask the user to confirm they are connected to the client network/VPN before continuing.

### 2) Discover expected Azure resource names from repos

Do this before querying Azure:

1. Read pipeline variables in:
   - `eutd-mmo-fes-pipeline-common/vars/common.yaml`
   - `eutd-mmo-fes-pipeline-common/vars/<environment>.yaml`
2. Resolve naming conventions and arrays for:
   - `webAppNames`
   - `functionApps`
   - `logicApps`
   - `logAnalyticsWorkspace`
   - `resourceGroupName`
   - related app insights naming variables
3. If any names remain ambiguous, inspect matching Bicep + bicepparam files in:
   - `eutd-mmo-fes-core-infra/templates/**`

### 3) Connect to Azure with least privilege

Use Azure MCP tools with user credentials and only read/query operations.
Recommended minimum RBAC scope: `Reader` + `Monitoring Reader` + `Log Analytics Data Reader` at the narrowest required scope.

### 4) Investigate with iterative time window

- If user provides a time window, honor it.
- Otherwise start at **last 1 hour**.
- If no meaningful issues found, expand iteratively: 2h → 4h → 8h → 12h → 24h.
- **Never analyze older than 24h** unless user explicitly asks and policy permits (this skill does not).

### 5) Correlate telemetry across services

Use Log Analytics `AzureDiagnostics` as the first-check source, then use Application Insights + Log Analytics table-specific queries to correlate requests, dependencies, traces, and exceptions across components.
For Web Apps, always inspect both:
- application logs (application/HTTP/runtime traces, exceptions)
- platform logs (App Service platform signals, infrastructure/runtime host events)

Use Azure Activity Logs when needed (for example restarts, config drift signals, platform-side incidents, RBAC/auth failures).

Track links via operation/correlation IDs and timestamps to identify upstream/downstream causality and probable root cause.

Ignore:
- warnings unless they are directly causal
- frontend React minified errors (non-actionable by default)

### 6) Branch-aware root cause analysis

For each impacted app, read the deployed branch from these public repos (as provided by user):
- https://github.com/DEFRA/eutd-mmo-fes-external-frontend
- https://github.com/DEFRA/eutd-mmo-fes-reference-data-reader
- https://github.com/DEFRA/eutd-mmo-fes-orchestration
- https://github.com/DEFRA/eutd-mmo-fes-landings-consolidation
- https://github.com/DEFRA/eutd-mmo-fes-function-app
- https://github.com/DEFRA/eutd-mmo-fes-batch-data-process
- https://github.com/DEFRA/eutd-mmo-fes-logic-apps
- https://github.com/DEFRA/eutd-mmo-fes-pdf
- https://github.com/DEFRA/eutd-mmo-fes-reference-shared-data

If branch info is missing, ask for it before asserting code-level root cause.

### 7) Internet-assisted diagnosis for generic/platform errors

For generic package/runtime/platform issues (for example npm dependency conflicts, authentication errors, Azure connectivity faults), research the exact error signatures using official docs first, then reputable sources.

### 8) Dead-end handling

If evidence is insufficient, explicitly state the dead end, what was checked, and the minimum additional data needed.

## Output format (mandatory)

Report findings in a clean table:

| Time window | Environment | Component | Resource | Error signature | Correlation IDs | Evidence (query/source) | Likely root cause | Confidence | Recommended next read-only checks |
|---|---|---|---|---|---|---|---|---|---|

Then include:
1. **Cross-service correlation summary**
2. **Primary root cause hypothesis** and alternatives
3. **Dead ends / unknowns**
4. **No-change confirmation:** "No Azure resources were modified. Read-only investigation only."

## Playbook

Use the query and triage templates in [Troubleshooting Playbook](references/TROUBLESHOOTING_PLAYBOOK.md).
When private endpoint access fails, use the standard response in the playbook section "Network access failure response template".
