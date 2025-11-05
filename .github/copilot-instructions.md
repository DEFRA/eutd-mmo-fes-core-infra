# Copilot Instructions

These rules guide AI assistance for this repository (infrastructure as code, Azure DevOps pipelines, and supporting PowerShell).

## General Azure Rules
- @azure Rule - Use Azure Code Gen Best Practices: Before generating Azure resource code (Bicep, ARM, scripts) or suggesting CLI/PowerShell for Azure, invoke the Azure best practices tool (resource=`general`, action=`code-generation`).
- @azure Rule - Use Azure Deployment Best Practices: Before proposing deployment steps, invoking scripts that deploy, or editing pipeline deployment stages, invoke best practices (resource=`general`, action=`deployment`).
- @azure Rule - Prefer Idempotent & Declarative: Recommend Bicep/ARM over imperative scripting when feasible; avoid hard‑coding subscription IDs or secrets.

## Bicep & Infrastructure as Code
- @bicep Rule - Consult Bicep Best Practices: Before editing any `*.bicep` file, read `/.github/instructions/bicep-code-best-practices.instructions.md` for style, modules, parameters, secure outputs.
- @bicep Rule - Validate Resource Types: Use Azure Bicep tooling to retrieve resource type schemas/API versions when adding new resources; prefer latest stable (not preview) unless feature requires preview.
- @bicep Rule - Reuse & Modules: Encourage composition via existing templates under `templates/` or Azure Verified Modules (AVM) rather than duplicating code.
- @bicep Rule - Naming & Tags: Enforce consistent naming conventions and mandatory tags (costCenter, environment, service, owner) when adding resources.
- @bicep Rule - Secure Parameters: Mark secrets as `@secure()` and avoid outputting secrets.
- @bicep Rule - Lint Before Commit: Recommend running bicep build/format/lint (if configured) after changes.

## Azure DevOps Pipelines (YAML)
- @pipelines Rule - Pipeline Best Practices: Before editing any `*azure-pipelines*.yml` or pipeline include file, review `/.github/instructions/azure-devops-pipelines.instructions.md`.
- @pipelines Rule - Separation of Concerns: Keep build, test, deploy stages distinct; do not mix infra and app build steps in a single job unless explicitly required.
- @pipelines Rule - Use Variable Groups & KeyVault: Reference secrets via variable groups or Key Vault tasks instead of inline.
- @pipelines Rule - Retry & Error Handling: Suggest strategy for transient failures (e.g., `retry`, `timeoutInMinutes`).
- @pipelines Rule - Template Reuse: Prefer central templates from `../ado-pipeline-common/templates/pipelines/` or `../eutd-mmo-fes-pipeline-common/includes/` before adding new logic.

## PowerShell Scripts
- @powershell Rule - Script Guidelines: Before modifying `*.ps1`/`*.psm1`, consult `/.github/instructions/powershell.instructions.md`.
- @powershell Rule - Functions & Verb-Noun: Use approved verbs and parameter validation (`[Parameter(Mandatory)]`). Support `-WhatIf` / `-Confirm` for destructive actions.
- @powershell Rule - Error Handling: Use `try { } catch { Write-Error ...; throw }`; avoid silent failures.
- @powershell Rule - Logging: Output clear progress messages with `Write-Host` (minimal) or structured logs; no secrets in logs.

## Security & Governance
- @security Rule - No Secrets in Code: Never commit connection strings, SAS tokens, or passwords. Use Key Vault and parameterize.
- @security Rule - Principle of Least Privilege: Recommend scoped identities (Managed Identity) vs broad service principals.
- @security Rule - TLS & Encryption: Ensure storage, databases, service bus enforce HTTPS and encryption at rest; flag if not set.

## Validation & Quality Gates
- @quality Rule - Pre-Change Checks: For infra changes, propose diff review (`what resources added/removed`), cost impact, and potential blast radius.
- @quality Rule - Post-Change Verification: Suggest validation steps (e.g., `az resource show`, log analytics query, or test invocation for functions/web apps) after deployment.

## Observability
- @monitoring Rule - Ensure Diagnostics: When adding new Azure resources, prompt to include diagnostic settings to Log Analytics workspace and relevant metrics/alerts.
- @monitoring Rule - Alert Consistency: Reference `create-alerts.yaml` for standard alert patterns; avoid duplicate alert definitions.

## Performance & Cost
- @cost Rule - Right-Size SKU: Recommend smallest SKU that meets requirements; highlight cost implications for premium tiers.
- @cost Rule - Avoid Unused Resources: Flag templates creating resources not referenced by downstream workloads.

## Collaboration & Consistency
- @collab Rule - Reference Existing Patterns: Before adding a new template under `templates/<service>`, search for an existing pattern (naming, parameters) and align.
- @collab Rule - Describe Changes: Encourage meaningful PR descriptions with resource diff summary and rollback plan.

## Tool Invocation Summary
Use Azure best practice tools BEFORE: (1) new Bicep resource code, (2) deployment plan authoring, (3) pipeline modifications for infra, (4) creating Azure Functions or other app service resources.

## Do Not
- @dont Rule - Do not embed secrets, GUIDs that vary per environment, or manual intervention steps without automation.
- @dont Rule - Avoid preview API versions unless justified and documented.

## Adjacent Recommendations
- @recommend Rule - Suggest test harness or validation scripts for critical infra (e.g., connectivity checks for VNet integration, key vault secret retrieval test).
- @recommend Rule - Prefer parameter files (`.bicepparam`) for environment-specific values.

---
These rules are additive to any organization-wide instructions and may evolve; update this file when new governance patterns or templates are introduced.
