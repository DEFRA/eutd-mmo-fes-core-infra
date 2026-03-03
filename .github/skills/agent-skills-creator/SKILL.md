---
name: agent-skills-creator
description: 'Guidelines for creating and updating GitHub Copilot Agent Skills (SKILL.md) with accurate discovery metadata, portable structure, and safe bundled resources. Use when asked to create a skill, new skill, custom skill, add/update SKILL.md, add content under .github/skills/, or improve skill discovery, slash-command behavior, or skill packaging.'
---

# Agent Skills Creation Guidelines

Use this skill whenever creating, updating, reviewing, or troubleshooting Agent Skills.

## Authoritative Sources

When creating or updating skills, align with:
- Agent Skills specification: https://agentskills.io/specification
- VS Code Copilot Agent Skills docs: https://code.visualstudio.com/docs/copilot/customization/agent-skills

## Mandatory Internet Research First

For any request to create, update, or troubleshoot an Agent Skill:
- Perform internet research first, before planning or editing files.
- Prioritize official sources (agentskills.io and VS Code/GitHub Copilot docs).
- If browsing is unavailable, stop and report the blocker; do not continue with stale assumptions.

## Skill Location and Structure

Preferred location: `.github/skills/<skill-name>/SKILL.md`

Required:
- `SKILL.md`

Optional:
- `scripts/` — executable automation
- `references/` — supporting docs loaded on demand
- `assets/` — static files used as-is
- `templates/` — starter files the agent modifies
- `LICENSE.txt` — if license terms are included

## Required Frontmatter

- `name` (required) — 1-64 chars, lowercase alphanumeric + hyphen, must match directory name
- `description` (required) — 1-1024 chars, clearly states what skill does and when to use it

Optional: `license`, `compatibility`, `metadata`, `allowed-tools`, `argument-hint`, `user-invokable`, `disable-model-invocation`

## `name` Rules

- 1-64 lowercase alphanumeric + hyphen characters
- No leading/trailing hyphens, no consecutive hyphens
- Must match parent directory name

## `description` Rules

- 1-1024 characters
- State what the skill does and when to use it
- Include realistic trigger keywords

## Body Content

Include: what the skill enables, when to use it, prerequisites, workflows, examples, edge cases, references to bundled resources via relative paths. Keep SKILL.md focused; move large details to `references/`.

## Progressive Loading

1. Discovery by `name` + `description` (~100 tokens)
2. Instructions from `SKILL.md` body (loaded on activation)
3. On-demand loading of referenced resources

Use relative paths from the skill root. Avoid deep reference chains.

## Security

- Never include secrets, tokens, credentials, or private keys
- Scripts must include clear error messages and safe defaults
- Destructive operations must require explicit intent
- Document network/external calls

## Creation Workflow

1. Research authoritative sources (internet research mandatory)
2. Create `.github/skills/<skill-name>/`
3. Add compliant `SKILL.md` with frontmatter and body
4. Add optional directories only when needed
5. Verify naming and discovery quality

## Validation Checklist

- YAML frontmatter is valid
- `name` and directory match exactly
- `name` and `description` meet constraints
- `description` includes capability + trigger keywords
- All referenced files exist with relative paths
- No secrets present
- Long workflows moved to `references/` when appropriate
