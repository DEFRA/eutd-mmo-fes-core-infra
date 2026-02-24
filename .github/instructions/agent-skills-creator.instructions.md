---
description: 'Guidelines for creating and updating GitHub Copilot Agent Skills (SKILL.md) with accurate discovery metadata, portable structure, and safe bundled resources.'
applyTo: '**'
---

# Agent Skills Creation Guidelines

Use this instruction whenever the request is about creating, updating, reviewing, or troubleshooting Agent Skills.

## Activation Trigger (Mandatory)

Treat this file as active if the user asks to:
- create a skill, new skill, or custom skill
- add/update `SKILL.md`
- add content under `.github/skills/` (or compatible skill locations)
- improve skill discovery, slash-command behavior, or skill packaging

If the request is not skill-related, do not enforce this file.

## Authoritative Sources

When creating or updating skills, align with:
- Agent Skills specification: https://agentskills.io/specification
- VS Code Copilot Agent Skills docs: https://code.visualstudio.com/docs/copilot/customization/agent-skills

## Mandatory Internet Research First

For any user request to create, update, or troubleshoot an Agent Skill:
- Perform internet research first, before planning or editing files.
- Prioritize official sources (agentskills.io and VS Code/GitHub Copilot docs).
- Do not ask for URL allowlists or browsing permission before researching.
- If browsing is blocked or unavailable, stop and report the blocker and minimum capability needed; do not continue with stale assumptions.

## Skill Location and Structure

Preferred repository location:
- `.github/skills/<skill-name>/SKILL.md`

A skill directory must contain at minimum:
- `SKILL.md`

Optional directories/files:
- `scripts/` for executable automation
- `references/` for supporting docs loaded on demand
- `assets/` for static files used as-is
- `templates/` for starter files the agent modifies
- `LICENSE.txt` if license terms are included

## Required `SKILL.md` Frontmatter

Include valid YAML frontmatter with:
- `name` (required)
- `description` (required)

Optional common fields:
- `license`
- `compatibility`
- `metadata`
- `allowed-tools` (experimental; support varies)

VS Code-specific optional fields (use when needed):
- `argument-hint`
- `user-invokable`
- `disable-model-invocation`

## `name` Rules (Strict)

`name` must:
- be 1-64 characters
- be lowercase alphanumeric plus hyphen
- not start/end with hyphen
- not contain consecutive hyphens
- match the parent skill directory name

## `description` Rules (Critical for Discovery)

`description` must:
- be 1-1024 characters
- clearly state what the skill does
- clearly state when to use it
- include realistic user keywords/triggers

Do not use vague descriptions (for example: "helpers" only).

## Body Content Guidance

After frontmatter, include concise operational Markdown:
- what the skill enables
- when to use it
- prerequisites
- step-by-step workflow(s)
- examples and edge cases
- references to bundled resources via relative paths

Prefer keeping `SKILL.md` focused and moving large details to `references/`.

## Progressive Loading and Resource Referencing

Design for progressive loading:
1. discovery by `name` + `description`
2. instructions from `SKILL.md` body
3. on-demand loading of referenced resources

Use relative paths from the skill root (for example `./references/guide.md`).
Avoid deep reference chains.

## Security and Safety Requirements

- Never include secrets, tokens, credentials, or private keys.
- Scripts must include clear error messages and safe defaults.
- Destructive operations must require explicit intent (for example explicit flags).
- Document network/external calls when included.

## Creation Workflow

When asked to create a new skill:
1. Complete mandatory internet research and confirm current guidance from authoritative sources.
2. Create `.github/skills/<skill-name>/`.
3. Add `SKILL.md` with compliant frontmatter and clear body sections.
4. Add optional `scripts/`, `references/`, `assets/`, `templates/` only when needed.
5. Add `LICENSE.txt` if license is declared by reference.
6. Verify naming and discovery quality before finishing.

## Validation Checklist

Before completion, confirm:
- frontmatter is valid YAML
- `name` and directory match exactly
- `name` and `description` meet constraints
- `description` includes capability + trigger keywords
- all referenced files exist and use relative paths
- no secrets are present
- long workflows are moved to `references/` when appropriate

If available, run a skill validator such as:
- `skills-ref validate <skill-directory>`
