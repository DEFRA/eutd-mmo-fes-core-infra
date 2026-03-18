---
description: 'Essential Bicep rules — full standards via bicep-linter-fixer skill'
applyTo: 'templates/**/*.bicep, templates/**/*.bicepparam'
---

# Bicep Essentials

- Prefer Azure Verified Modules (AVM); use Bicep resources only when no AVM module fits
- Use lowerCamelCase for all names; descriptive symbolic names; no `-name` suffix
- Add `@description` on every parameter; `@secure()` on secrets
- Use latest stable API versions; no preview unless explicitly required
- Use symbolic references; no unnecessary `dependsOn`; use `existing` keyword
- No secrets in outputs; no hardcoded keys
- Use variables for complex expressions; rely on type inference
- Use parent property or nesting for child resources; avoid name construction
- Prefer existing `templates/` patterns or AVM over duplication
- For full standards, AVM discovery, and examples: invoke the `/bicep-linter-fixer` skill
