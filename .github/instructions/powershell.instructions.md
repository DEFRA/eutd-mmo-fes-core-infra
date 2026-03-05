---
applyTo: 'scripts/*.ps1'
description: 'Essential PowerShell rules — full standards via powershell-quality-enforcer skill'
---

# PowerShell Essentials

- Use Verb-Noun function names with approved verbs; PascalCase
- Use `[CmdletBinding()]` and `[Parameter(Mandatory)]` validation
- Use `SupportsShouldProcess` for destructive operations
- Use `try/catch` with `Write-Error`; `throw` for terminating errors
- Use `Write-Host` for logging — **no color parameters** (`-ForegroundColor` etc.)
- Use `Write-Output` **only** for `##vso[task.setvariable]` pipeline variables
- Do NOT use `Write-Verbose` or `Write-Warning` unless explicitly requested
- No aliases in scripts — use full cmdlet names (`Get-ChildItem` not `gci`)
- Include comment-based help (`.SYNOPSIS`, `.DESCRIPTION`, `.EXAMPLE`) on public functions
- For full standards with examples: invoke the `/powershell-quality-enforcer` skill
