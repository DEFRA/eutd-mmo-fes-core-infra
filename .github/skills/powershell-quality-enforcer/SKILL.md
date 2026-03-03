---
name: powershell-quality-enforcer
description: 'PowerShell coding standards and quality enforcement for scripts and modules. Use when (1) writing or editing PowerShell scripts (.ps1, .psm1), (2) audit or review scripts for quality, (3) enforce Verb-Noun naming or parameter validation, (4) fix style issues like aliases or missing error handling, (5) add SupportsShouldProcess or WhatIf/Confirm to destructive functions, (6) improve logging and Write-Host/Write-Output usage, or (7) ensure comment-based help is present.'
---

# PowerShell Coding Standards & Quality Enforcer

## Key Standards

| Category | Rule |
|----------|------|
| Naming | Verb-Noun functions (approved verbs); PascalCase; no aliases in scripts |
| Parameters | `[Parameter(Mandatory)]`; `ValidateSet`/`ValidateNotNullOrEmpty`; singular form |
| Safety | `SupportsShouldProcess` + `-WhatIf`/`-Confirm` on destructive actions |
| Errors | `try/catch` with `Write-Error`; `throw` for terminating errors |
| Logging | `Write-Host` without color params for logging; `Write-Output` only for `##vso` pipeline variables |
| Pipeline | `ValueFromPipeline`; Begin/Process/End blocks; return objects not text |
| Documentation | Comment-based help (`.SYNOPSIS`, `.DESCRIPTION`, `.EXAMPLE`) on public functions |
| Style | Full cmdlet names; 4-space indent; no abbreviations |

For full standards with examples, see [PowerShell coding standards reference](./references/powershell-coding-standards.md).

## Quality Enforcement Workflow

### 1. Target files

Default scope: `**/*.ps1`, `**/*.psm1`. Narrow when user specifies.

### 2. Quality rules

| Category | Rule |
|----------|------|
| Naming | Approved Verb-Noun function names; clear parameter names |
| Safety | `SupportsShouldProcess` + `-WhatIf`/`-Confirm` on destructive actions |
| Errors | `try/catch` with `Write-Error`; terminate where appropriate |
| Logging | `Write-Host` for logs (no color params); `Write-Output` only for pipeline returns |
| Style | Full cmdlet and parameter names; no aliases in scripts |
| Docs | Comment-based help on public functions |

### 3. Change policy

- **Audit-only request** — report violations, do not edit files.
- **Fix request** — apply focused, deterministic edits only. Preserve script behaviour and interfaces.

### 4. Validation and output

Re-check changed files, then report:

1. **Summary** — files scanned, violations found, fixes applied
2. **Violations table**:

| File | Line | Rule | Severity | Recommendation |
|------|------|------|----------|----------------|

3. **Applied changes** (if any)
4. **Remaining manual actions** — items needing user judgement

Example summary line:

> Scanned 3 files · 5 violations found · 3 fixed · 2 manual follow-ups
