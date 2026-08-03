# Copilot Instructions

These rules guide AI assistance for this repository (infrastructure as code, Azure DevOps pipelines, and supporting PowerShell).

These guidelines apply to **every** chat request in this workspace and are inherited by the custom
workflow agents: [Orchestrator](agents/orchestrator.agent.md), [Planner](agents/planner.agent.md),
[DevOps](agents/devops-agent.agent.md) and [Reviewer](agents/reviewer.agent.md).

---

## Standards precedence (highest wins)

When guidance conflicts, follow this order:

1. **DEFRA Software Development Standards** (mandatory) — https://defra.github.io/software-development-standards/
2. **DEFRA Digital Service Manual** — https://digital.defra.gov.uk/service-manual
3. **GOV.UK Service Standard & Service Manual (GDS)** — https://www.gov.uk/service-manual
4. **Microsoft Azure guidance** — Well-Architected Framework, Azure Verified Modules (AVM), and Azure DevOps best practices
5. **Community best practice** — OWASP, and widely-adopted IaC / pipeline / PowerShell patterns

> **DEFRA takes precedence over GDS. GDS takes precedence over Microsoft/community guidance.**
> Any deviation from a DEFRA standard MUST be raised as a formal exception through DEFRA's
> architectural governance (Delivery Architecture team: `delivery.architecture@defra.gov.uk`).

## Mandatory DEFRA constraints (apply to all work)

- **Code in the open** in the [DEFRA GitHub org](https://github.com/DEFRA); analyse quality in
  [DEFRA SonarCloud](https://sonarcloud.io/organizations/defra) where configured.
- **Never commit secrets.** No connection strings, SAS tokens, certificates or passwords in source; use
  Key Vault and parameterise. Follow DEFRA's
  [credential exposure](https://defra.github.io/software-development-standards/processes/credential_exposure/) process if a secret leaks.
- **Secure by Design** (https://www.security.gov.uk/guidance/secure-by-design/principles/).
- **Principle of least privilege** — prefer scoped Managed Identity over broad service principals.
- **Encryption in transit and at rest** — enforce HTTPS/TLS and encryption for storage, databases and
  messaging; flag any resource that does not.
- **Observability by default** — new resources ship with diagnostic settings to Log Analytics and the
  relevant metrics/alerts (see `create-alerts.yaml`).
- Maintain a README to DEFRA
  [README standards](https://defra.github.io/software-development-standards/standards/readme_standards/),
  plus ADRs (`docs/adr/`) and architecture diagrams for non-trivial change.

## Workspace topology & the public/private boundary

This is a **multi-root workspace** spanning three repositories. Agents read across all of them for
context, but must respect a strict **public/private boundary**.

- **`eutd-mmo-fes-core-infra` — PUBLIC (code in the open).** Holds the Bicep templates (`templates/`),
  the entry pipeline YAMLs (`infra-deploy.yml`, `create-alerts.yaml`, `ssv5-deploy.yml`, …) and the
  `.github/` agents, instructions and skills. **This is where the agent files live.**
- **`eutd-mmo-fes-pipeline-common` — PRIVATE.** Holds the extended pipeline templates (`includes/`,
  `templates/`), pipeline variables (`vars/`), PowerShell automation (`scripts/`), reference data
  (`reference-data-files/`) and runbooks (`docs/runbooks/`). Core-infra pipelines consume it through the
  `resources.repositories` alias `MMOPipelineCommon`
  (e.g. `template: /includes/infra-deploy.yaml@MMOPipelineCommon`).
- **`ado-pipeline-common` — DEFRA org-level shared pipeline templates** (`templates/pipelines`,
  `templates/powershell`, `templates/steps`), consumed as a versioned reference.

**The boundary rule (mandatory):**

- Agents **may read** `eutd-mmo-fes-pipeline-common` to understand how templates, variables and scripts
  work, and to plan or validate changes.
- Agents **must NOT divulge private content** from `eutd-mmo-fes-pipeline-common` into the **public**
  `eutd-mmo-fes-core-infra` repo. Never copy or inline private script bodies, variable values, template
  internals, reference data, runbook detail or internal identifiers into core-infra Bicep, pipeline YAML,
  `.github/` files, commit messages, PR descriptions, ADRs or code comments.
- Reference private assets **by path/alias** (`@MMOPipelineCommon`, template paths), never by inlining
  their content into public files.
- **Put each change in the correct repo:** shared pipeline templates, variables, scripts, reference data
  and runbooks belong in `eutd-mmo-fes-pipeline-common`; Bicep and the entry pipeline YAMLs belong in
  `eutd-mmo-fes-core-infra`. Do not relocate private assets into the public repo to "make it work".
- The **code-in-the-open** constraint above applies to `eutd-mmo-fes-core-infra`; treat
  `eutd-mmo-fes-pipeline-common` as the private exception and keep its content within that repo.

## The working framework (Triage → Read → Research → Plan Handoff → Plan Validation Research → Approval → Implement → Test → Iterate → Summarise)

This section is the **single source of truth** for the working loop. Custom agents reference it and
**must not restate or fork it**.

**Triage first — pick the right path by size and risk:**

- **Trivial / low-risk** (typo, comment/doc tweak, a small localised change with no impact on infrastructure
  architecture, networking, identity/RBAC, security, state/backend, deployment topology or cost): skip the
  planner and heavy research. Do a light **Read → Implement → Test → Summarise**, and research only the
  specific point that is genuinely uncertain.
- **Non-trivial** (new resources/modules, pipeline changes, networking, identity/RBAC, security, state or
  backend changes, cost-significant work, or anything with deployment blast radius): run the full loop below.

Non-trivial loop:

1. **Read** — Read the relevant templates/pipelines/scripts/config in the repo for context before acting.
  Never assume; verify.
2. **Research** — Do thorough internet research in the open, **scoped to the task's risk**, and validate
  findings against DEFRA/GDS, Microsoft Azure and framework guidance so advice reflects current APIs,
  resource versions and policy. Cite sources.
3. **Clarify** — Ask the user targeted questions whenever requirements are ambiguous or missing. Surface
  requirement gaps explicitly with suggested fixes. Do not guess at intent.
4. **Plan handoff** — Delegate planning to the [Planner](agents/planner.agent.md) agent when one is needed.
  The planning agent returns the complete implementation plan.
5. **Plan validation research** — The Planner performs thorough research in the open to validate the plan
  against DEFRA/GDS, Microsoft Azure and framework guidance, **focusing on the steps flagged as risky or
  version-sensitive** (preview API versions, security, identity/RBAC, cost, breaking changes). Targeted
  revisions go back to the Planner.
6. **Approval** — Present the complete validated plan to the user and obtain explicit approval before
  implementation. If changes are requested, update the plan, re-validate, and re-approve. **Cap the
  plan → validate → approve → implement replanning cycle at 3 iterations**; if it is still unresolved,
  stop and surface the blocker to the user instead of looping.
7. **Implement** — Deliver one task at a time (or parallel independent tasks) from the approved plan.
  Stay focused on the requested outcome; do not scope-creep or refactor unrelated code. **When starting
  work on new architecture, create the required ADR(s) first** under `docs/adr/`, then build against them.
8. **Test / Validate** — Build/lint/format (`bicep build`, `bicep lint`, `az bicep format`), run a
  deployment preview (`az deployment ... what-if`) and template validation (ARM-TTK), lint scripts
  (`PSScriptAnalyzer`) and validate pipelines before merge; confirm each task works before moving on.
9. **Iterate** — Refine until the user is satisfied with each task.
10. **Summarise** — End with a detailed **executive summary** of what changed, why, how it was validated,
  and any follow-ups or risks (resource diff, cost impact, blast radius, rollback plan).

## Workflow agents

Complex, multi-step work is coordinated through four agents that run the framework above:

- **[Orchestrator](agents/orchestrator.agent.md)** — coordinates the loop and owns the user-approval gate;
  plans, delegates, verifies and reports. Does not edit files or run commands itself.
- **[Planner](agents/planner.agent.md)** — produces the complete, approval-ready plan and does the
  open/internet research behind it (via the
  [deep-research-defra-alignment](skills/deep-research-defra-alignment/SKILL.md) skill).
- **[DevOps](agents/devops-agent.agent.md)** — implements an already-approved plan end-to-end (Bicep, ADO
  YAML pipelines, PowerShell) and ships the validation with it.
- **[Reviewer](agents/reviewer.agent.md)** — read-only review of the completed change against DEFRA
  standards, security, IaC/pipeline/PowerShell conventions, cost and observability, reported by severity.

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
