---
name: secure-parameterization-guard
description: Audit for hardcoded secrets and environment-specific identifiers across Bicep, YAML pipelines, JSON, and PowerShell files, then report findings with remediation guidance. Does NOT modify code by default — only proposes fixes unless the user explicitly requests changes. Use this when asked to (1) scan for secret leakage or credential exposure, (2) detect hardcoded subscription, tenant, or client IDs, (3) audit security posture of infrastructure code, (4) check for inline passwords, tokens, SAS strings, or connection strings, (5) verify secrets are stored in Key Vault and not in source, or (6) perform a security review of pipelines or scripts.
---

# Critical constraint

**Do not modify code by default.** Report findings and propose fixes only. Apply edits solely when the user explicitly requests remediation.

# Workflow

## 1. Load repository guidance

Read before scanning:

- `.github/copilot-instructions.md`
- `.github/skills/bicep-linter-fixer/references/bicep-coding-standards.md`
- `.github/skills/pipeline-best-practices/references/pipeline-coding-standards.md`
- `.github/skills/powershell-quality-enforcer/references/powershell-coding-standards.md`

## 2. Scan scope

Default: full repository. File types: `*.bicep`, `*.bicepparam`, `*.json`, `*.yml`, `*.yaml`, `*.ps1`, `*.psm1`.

### Detection targets

| Category | Examples |
|----------|----------|
| Plaintext secrets | Passwords, API keys, SAS tokens, connection strings |
| Hardcoded IDs | Subscription IDs, tenant IDs, client/object IDs |
| Inline credentials | Credentials embedded in pipeline variables or script literals |
| Exposed secrets | Secrets surfaced in outputs or log statements |

## 3. Classify severity

- **critical** — Plaintext secret or credential in source
- **high** — Hardcoded environment-specific ID (subscription, tenant)
- **medium** — Secret-like pattern that may be a false positive
- **low** — Informational (e.g., `@secure()` missing but no value exposed)

## 4. Reporting

Mask sensitive values — never print full secrets.

Output sections:

1. **Summary** — counts by severity
2. **Findings table**:

| File | Line | Issue | Severity | Masked evidence | Recommended fix |
|------|------|-------|----------|----------------|-----------------|

3. **Prioritised remediation plan** — Key Vault, variable groups, `@secure()`, managed identity
4. **No-change confirmation** — "No files were modified."

## 5. Remediation (only when user explicitly requests)

1. Present a patch plan and get confirmation.
2. Apply minimal, reversible edits.
3. Re-scan changed files and report residual risk.
