# Copilot Instructions

These rules guide AI assistance for this repository (infrastructure as code, Azure DevOps pipelines, and supporting PowerShell).

## General Azure Rules
- @azure Rule - Use Azure Code Gen Best Practices: Before generating Azure resource code (Bicep, ARM, scripts) or suggesting CLI/PowerShell for Azure, invoke the Azure best practices tool (resource=`general`, action=`code-generation`).
- @azure Rule - Use Azure Deployment Best Practices: Before proposing deployment steps, invoking scripts that deploy, or editing pipeline deployment stages, invoke best practices (resource=`general`, action=`deployment`).
- @azure Rule - Prefer Idempotent & Declarative: Recommend Bicep/ARM over imperative scripting when feasible; avoid hard‑coding subscription IDs or secrets.

## Domain-Specific Standards

Detailed coding standards are provided through agent skills that auto-load when relevant:
- **Bicep**: `bicep-linter-fixer` skill — naming, parameters, AVM, security conventions for `*.bicep` files
- **Pipelines**: `pipeline-best-practices` skill — structure, variables, templates, deployment for `azure-pipelines*.yml`
- **PowerShell**: `powershell-quality-enforcer` skill — Verb-Noun, error handling, logging for `*.ps1`/`*.psm1`
- **Security**: `secure-parameterization-guard` skill — secrets audit, hardcoded IDs across all file types

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
