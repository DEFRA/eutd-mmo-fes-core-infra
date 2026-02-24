---
name: bicep-linter-fixer
description: Detect and fix Bicep lint and best-practice issues in this repository. Use this when asked to improve Bicep quality, enforce standards, or remediate lint findings. Triggers include requests to (1) lint or validate Bicep files, (2) fix Bicep warnings or errors, (3) enforce Bicep naming, parameter, or security conventions, (4) review Bicep templates for best-practice compliance, (5) remediate Bicep code quality issues, or (6) align Bicep code with Azure Verified Module (AVM) patterns.
---

# Workflow

## 1. Load repository guidance

Read these files before making any edits:

- `.github/copilot-instructions.md`
- `.github/instructions/bicep-code-best-practices.instructions.md`

## 2. Scope discovery

- Default scope: `templates/**/*.bicep`. Narrow when user specifies files.
- Preserve module structure and existing deployment intent.

## 3. Checks to enforce

| Category | Rule |
|----------|------|
| Parameters | Every parameter has `@description`; sensible defaults; `@secure()` on secrets |
| Naming | lowerCamelCase symbolic names; descriptive identifiers; no `-name` suffix |
| API versions | Latest stable; no preview unless explicitly required |
| References | Symbolic references; no unnecessary `dependsOn` |
| Security | No secrets in outputs; no hardcoded keys |
| Reuse | Prefer AVM modules or existing `templates/` patterns over duplication |

## 4. Fix policy

- Apply minimal, targeted edits to deterministic issues only.
- Do not refactor broadly or alter runtime behavior.
- When ambiguity exists (e.g., competing naming conventions), ask before changing.

## 5. Validation and reporting

Re-scan modified files, then output:

| Column | Content |
|--------|---------|
| File | Relative path |
| Rule | Short rule name |
| Severity | `error` / `warning` / `info` |
| Action | `fixed` / `manual` / `skipped` |

Example summary line:

> Scanned 6 files · 4 violations fixed · 1 manual follow-up remaining
