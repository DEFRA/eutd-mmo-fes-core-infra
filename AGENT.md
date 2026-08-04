---
name: Agent (Default)
description: Default agent profile for this repository.
tools: ['vscode/getProjectSetupInfo', 'vscode/installExtension', 'vscode/newWorkspace', 'vscode/runCommand', 'vscode/vscodeAPI', 'vscode/extensions', 'execute', 'read', 'edit', 'search', 'web', 'microsoftdocs/mcp/*', 'bicep/*', 'agent', 'microsoft/azure-devops-mcp/*', 'todo']
---

# Workflow Agents Reference

This is the default Copilot agent profile for this repository.

Complex, multi-step work is coordinated through four workflow agents that run the working framework
defined in [.github/copilot-instructions.md](.github/copilot-instructions.md):

- **[Orchestrator](.github/agents/orchestrator.agent.md)** — default entry point for complex work;
  coordinates the loop and owns the user-approval gate. Delegates; does not edit files itself.
- **[Planner](.github/agents/planner.agent.md)** — produces the approval-ready plan and the research behind it.
- **[DevOps](.github/agents/devops-agent.agent.md)** — implements an already-approved plan (Bicep, ADO YAML
  pipelines, PowerShell) and ships the validation.
- **[Reviewer](.github/agents/reviewer.agent.md)** — read-only, severity-graded review of the change.

Start with the **[Orchestrator](.github/agents/orchestrator.agent.md)** for non-trivial tasks; use the
**[DevOps](.github/agents/devops-agent.agent.md)** agent directly for trivial, low-risk changes.
