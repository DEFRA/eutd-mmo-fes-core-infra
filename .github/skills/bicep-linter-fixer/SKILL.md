---
name: bicep-linter-fixer
description: 'Bicep coding standards and lint/fix enforcement for infrastructure as code. Use when (1) writing or editing Bicep files, (2) lint or validate Bicep templates, (3) fix Bicep warnings or errors, (4) enforce naming, parameter, or security conventions, (5) review Bicep templates for best-practice compliance, (6) remediate code quality issues, or (7) align with Azure Verified Module (AVM) patterns.'
---

# Bicep Coding Standards & Lint Fixer

## Key Standards

| Category | Rule |
|----------|------|
| AVM First | Prefer Azure Verified Modules; use Bicep resources only when no AVM module fits |
| Naming | lowerCamelCase for all names; descriptive symbolic names; no `-name` suffix |
| Parameters | `@description` on every parameter; sensible defaults; `@secure()` on secrets |
| API Versions | Latest stable; no preview unless explicitly required |
| References | Symbolic references; no unnecessary `dependsOn`; use `existing` keyword |
| Security | No secrets in outputs; no hardcoded keys |
| Variables | Use variables for complex expressions; rely on type inference |
| Child Resources | Use parent property or nesting; avoid name construction |
| Documentation | Include `//` comments for readability |

For full standards, AVM discovery links, and examples, see [Bicep coding standards reference](./references/bicep-coding-standards.md).

## Lint/Fix Workflow

### 1. Scope discovery

- Default scope: `templates/**/*.bicep`. Narrow when user specifies files.
- Preserve module structure and existing deployment intent.

### 2. Checks to enforce

| Category | Rule |
|----------|------|
| Parameters | Every parameter has `@description`; sensible defaults; `@secure()` on secrets |
| Naming | lowerCamelCase symbolic names; descriptive identifiers; no `-name` suffix |
| API versions | Latest stable; no preview unless explicitly required |
| References | Symbolic references; no unnecessary `dependsOn` |
| Security | No secrets in outputs; no hardcoded keys |
| Reuse | Prefer AVM modules or existing `templates/` patterns over duplication |

### 3. Fix policy

- Apply minimal, targeted edits to deterministic issues only.
- Do not refactor broadly or alter runtime behavior.
- When ambiguity exists (e.g., competing naming conventions), ask before changing.

### 4. Validation and reporting

Re-scan modified files, then output:

| Column | Content |
|--------|---------|
| File | Relative path |
| Rule | Short rule name |
| Severity | `error` / `warning` / `info` |
| Action | `fixed` / `manual` / `skipped` |

Example summary line:

> Scanned 6 files · 4 violations fixed · 1 manual follow-up remaining
