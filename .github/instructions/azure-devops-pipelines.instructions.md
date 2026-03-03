---
description: 'Essential pipeline rules — full standards via pipeline-best-practices skill'
applyTo: '*.yml, *.yaml, includes/*.yaml, templates/*.yaml, vars/**/*.yaml'
---

# Azure DevOps Pipeline Essentials

- Use stages for build → test → deploy; keep concerns separate
- Include meaningful names and displayNames for stages, jobs, and steps
- Use variable groups and Key Vault; never hardcode secrets inline
- Prefer central templates from `ado-pipeline-common` or `eutd-mmo-fes-pipeline-common` over new logic
- Service connections with minimum permissions; managed identities preferred
- Use 2-space YAML indentation consistently
- Add path filters to triggers to avoid unnecessary builds
- Add retry strategies and `timeoutInMinutes` for transient failures
- Include rollback mechanisms and health checks for deployments
- For full standards, examples, and anti-patterns: invoke the `/pipeline-best-practices` skill
