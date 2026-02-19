---
name: powershell-quality-enforcer
description: Enforce repository PowerShell quality and safety standards, and fix deterministic script quality violations when requested. Use this when asked to (1) audit or review PowerShell scripts for quality, (2) enforce Verb-Noun naming or parameter validation, (3) fix PowerShell style issues such as aliases or missing error handling, (4) add SupportsShouldProcess or WhatIf/Confirm to destructive functions, (5) improve PowerShell logging and Write-Host/Write-Output usage, or (6) ensure comment-based help is present on public functions.
---

# Workflow

## 1. Load repository guidance

Read before scanning or editing:

- `.github/copilot-instructions.md`
- `.github/instructions/powershell.instructions.md`

## 2. Target files

Default scope: `**/*.ps1`, `**/*.psm1`. Narrow when user specifies.

## 3. Quality rules

| Category | Rule |
|----------|------|
| Naming | Approved Verb-Noun function names; clear parameter names |
| Safety | `SupportsShouldProcess` + `-WhatIf`/`-Confirm` on destructive actions |
| Errors | `try/catch` with `Write-Error`; terminate where appropriate |
| Logging | `Write-Host` for logs (no color params); `Write-Output` only for pipeline returns |
| Style | Full cmdlet and parameter names; no aliases in scripts |
| Docs | Comment-based help on public functions |

## 4. Change policy

- **Audit-only request** — report violations, do not edit files.
- **Fix request** — apply focused, deterministic edits only. Preserve script behaviour and interfaces.

## 5. Validation and output

Re-check changed files, then report:

1. **Summary** — files scanned, violations found, fixes applied
2. **Violations table**:

| File | Line | Rule | Severity | Recommendation |
|------|------|------|----------|----------------|

3. **Applied changes** (if any)
4. **Remaining manual actions** — items needing user judgement

Example summary line:

> Scanned 3 files · 5 violations found · 3 fixed · 2 manual follow-ups
