---
name: setup-adapt
description: Enforces adapt-not-copy and scaffolding cleanup during project setup
type: ttsr
version: 1.0.0
---

# Setup Adapt Rule

## Purpose

Prevents agents from:
1. Copying template files verbatim instead of adapting them
2. Leaving scaffolding files (`SETUP_GUIDE.md`, `ADOPTING.md`, `UPGRADING.md`) after setup completes

This rule activates during setup-related activity to inject adaptation requirements **at the moment the agent is doing the work** — regardless of whether the `setup` skill was loaded.

## Trigger Patterns

This rule activates via TTSR (zero upfront context cost) when the agent's output stream matches **any** of these patterns:

| Pattern | What It Catches |
|---------|-----------------|
| `SETUP_GUIDE\.md` | Agent mentions or references the setup guide |
| `ADOPTING\.md` | Agent mentions or references the adopting guide |
| `UPGRADING\.md` | Agent mentions or references the upgrading guide |
| `## \[0\.\d+\.\d+\]` | CHANGELOG.md content with template version entries |
| `<!-- .* --><!-- .* -->` | Template placeholder HTML comments being copied |

### Why These Patterns?

- `SETUP_GUIDE.md`, `ADOPTING.md`, `UPGRADING.md` — Scaffolding files that must be removed after setup
- `## [0.x.x]` — Template version entries in CHANGELOG.md indicate the agent copied the template's entire history instead of starting fresh
- Placeholder HTML comments — Template markers that should not appear in customized project files

## ADAPT, Never Copy

Each template file requires a specific adaptation approach:

| File | Rule | Why |
|------|------|-----|
| `CHANGELOG.md` | **Start fresh** — begin with `[Unreleased]` only. Do not copy template version history. | Template version history is irrelevant noise for adopting projects. |
| `AGENTS.md` | **Derive from codebase** — infer project name from directory, language from manifest files, build commands from existing scripts. | Copying placeholder content leaves incomplete project context. |
| `README.md` | **Replace template text** — describe the actual project, not the template. | Template README is for reference, not publication. |
| `ARCHITECTURE.md` | **Use as scaffold** — keep structure, fill with actual architecture or explicit TODOs. | Architecture is project-specific. |
| `CONTRIBUTING.md` | **Adapt to project** — use template as style reference, reflect actual conventions. | Conventions vary by project. |
| `.gitignore` | **Start from language defaults** — generate fresh, don't copy template verbatim. | Template's gitignore may include irrelevant entries. |

## Scaffolding Cleanup

After setup completes, **MUST** remove these files:

```bash
rm -f SETUP_GUIDE.md ADOPTING.md UPGRADING.md
```

These files document the setup process for agents, but once setup is complete:
- `SETUP_GUIDE.md` — Replaced by the interactive `setup` skill
- `ADOPTING.md` — Not relevant for greenfield projects
- `UPGRADING.md` — No prior version to upgrade from

## Reference

For the full setup workflow, load the `setup` skill:
```
skill://setup/SKILL.md
```

The skill provides step-by-step guidance including:
- Context detection (greenfield vs. existing repo)
- Feature group selection
- Per-file generation rules
- Cleanup requirements

## Anti-Patterns

| ❌ Do NOT | ✅ Do Instead |
|----------|---------------|
| Copy `CHANGELOG.md` verbatim — you'll inherit template version history | Start with empty `[Unreleased]` section |
| Copy template `AGENTS.md` placeholders — they indicate incomplete setup | Derive project info from actual codebase (name, language, commands) |
| Leave `SETUP_GUIDE.md` after setup — scaffolding persists | Remove all three scaffolding files as final step |
| Say "Copy from template" — this instructs verbatim copying | Say "Generate from template" — this instructs intelligent adaptation |
| Include placeholder HTML comments (`<!-- e.g. -->`) in project files | Remove all placeholders or fill with actual content |

## Consequences

| Violation | Consequence |
|-----------|------------|
| Scaffolding files not removed | CI `audit.sh` check fails with "scaffolding was not cleaned up" |
| Template CHANGELOG history copied | Template version entries (`## [0.x.x]`) appear in adopted project CHANGELOG |
| Placeholder comments remain | CI `blob-size-policy.yml` workflow fails on PR |
| AGENTS.md copied verbatim | AI agents receive wrong project context — generic contributions result |
