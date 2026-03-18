---
name: pipeline-best-practices
description: 'Azure DevOps pipeline YAML best practices for authoring, reviewing, and troubleshooting CI/CD pipelines. Use when asked to (1) create or edit azure-pipelines YAML files, (2) review pipeline structure or stages, (3) fix pipeline errors or anti-patterns, (4) optimize pipeline performance or caching, (5) implement deployment strategies, or (6) enforce pipeline security, variable management, or template reuse conventions.'
---

# Azure DevOps Pipeline Best Practices

## Key Rules

| Category | Rule |
|----------|------|
| Structure | Use stages for build → test → deploy; keep concerns separate |
| Naming | Meaningful names and displayNames for stages, jobs, and steps |
| Variables | Use variable groups and Key Vault; never hardcode secrets inline |
| Templates | Prefer central templates from `ado-pipeline-common` or `eutd-mmo-fes-pipeline-common` |
| Security | Service connections with minimum permissions; managed identities preferred |
| Testing | Publish test results; include code coverage; fail fast on failures |
| Caching | Cache dependencies (npm, NuGet, etc.) for build performance |
| Triggers | Path filters to avoid unnecessary builds; branch-specific triggers |
| Error handling | Add retry strategies and timeoutInMinutes for transient failures |
| Deployment | Environment promotion (dev → staging → prod); include rollback mechanisms |

## Workflow

### 1. Scope

Default scope: `**/azure-pipelines*.yml`, `**/*.pipeline.yml`, and pipeline include files.

### 2. Before editing

- Check existing templates in `ado-pipeline-common/templates/pipelines/` and `eutd-mmo-fes-pipeline-common/includes/`
- Prefer reusing or extending existing templates over new logic

### 3. Quality checks

- Validate YAML syntax with 2-space indentation
- Verify no hardcoded secrets or environment-specific values
- Ensure proper stage dependencies and conditional execution
- Check that triggers use appropriate path filters

### 4. Anti-patterns to flag

- Hardcoded sensitive values in YAML
- Overly broad triggers causing unnecessary builds
- Mixed build and deployment logic in a single stage
- Missing error handling and cleanup
- Deprecated task versions
- Monolithic pipelines that are difficult to maintain

For detailed standards, examples, and YAML structure templates, see [pipeline coding standards](./references/pipeline-coding-standards.md).
