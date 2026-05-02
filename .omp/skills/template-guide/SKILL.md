---
name: template-guide
description: Navigate template conventions, audit compliance, and guide upgrades for ai-project-template repos
category: project-management
tags: [template, conventions, compliance, upgrade]
version: 1.0.0
template-version: 0.6.0
---

# Template Guide

A skill for navigating `ai-project-template` conventions, auditing compliance, and guiding upgrades.

## When to Use

Invoke this skill when:

- You are new to a project scaffolded from `ai-project-template`
- You are reviewing a PR against a project using this template
- You need to check whether a project follows template conventions
- A user asks how to update their project to a newer template version
- You encounter a file you don't recognize and need to understand its purpose

## Conventions Reference

### Core Files

| File | Purpose | Key sections |
|---|---|---|
| `AGENTS.md` | Project-level context for AI coding agents | Project Overview, Build & Run, Code Style, CI/CD, Agent Behavior |
| `README.md` | Human-facing project documentation | Features, Quick Start, What's Included, Documentation |
| `CONTRIBUTING.md` | Development guidelines | Commits, Branches, Changelog, Code Review |
| `CHANGELOG.md` | Version history (Keep a Changelog format) | `[Unreleased]`, `[0.x.0]` headers with Added/Changed/Fixed/Removed |
| `ARCHITECTURE.md` | System design documentation | Components, data flow, dependencies |
| `UPGRADING.md` | Re-sync guide for template upgrades | Version check, diff, merge, verify |
| `ADOPTING.md` | First-time adoption guide for existing repos | Pre-flight audit, incremental adoption phases |
| `SETUP_GUIDE.md` | Greenfield setup instructions | Required info, setup checklist, quality gates |

### CI/CD Files

| File | Purpose | Trigger |
|---|---|---|
| `.github/workflows/ci.yml` | Lint, typecheck, test | push + PR to main |
| `.github/workflows/commit-lint.yml` | Enforces Conventional Commits | PR + push |
| `.github/workflows/changelog-check.yml` | Requires CHANGELOG.md updates | PR only |
| `.github/workflows/blob-size-policy.yml` | Rejects oversized files | PR only |
| `docs/ci.md` | CI architecture guide | Reference |

### Agent Configuration

| File/Directory | Purpose |
|---|---|
| `.omp/agents/` | Agent definitions (code-reviewer, adr-writer, changelog-updater) |
| `.omp/skills/` | Agent skills (e.g., `template-guide`) |
| `.omp/settings.json` | OMP configuration |
| `.omp/rules/` | Agent rules |
| `.omp/hooks/` | Pre/post hooks |
| `.omp/tools/` | Agent tools |

### Code Quality

| File | Purpose |
|---|---|
| `.architecture.yml` | Code quality thresholds (max file lines, function lines, exports, nesting) |
| `.editorconfig` | Editor settings |
| `docs/agent-files-guide.md` | Guide for writing AGENTS.md, ARCHITECTURE.md, SKILL.md |

## Compliance Checklist

Run `.omp/skills/template-guide/scripts/audit.sh` to check all items, or verify manually:

### Required Files

- [ ] `AGENTS.md` — exists and has no `<!-- -->` placeholders
- [ ] `README.md` — exists and describes the project (not generic template text)
- [ ] `CHANGELOG.md` — exists and has `[Unreleased]` section
- [ ] `CONTRIBUTING.md` — exists
- [ ] `ARCHITECTURE.md` — exists (root or in `docs/`)

### CI Workflows

- [ ] `.github/workflows/commit-lint.yml` — present
- [ ] `.github/workflows/changelog-check.yml` — present
- [ ] `.github/workflows/blob-size-policy.yml` — present

### Versioning

- [ ] `.template-version` — exists and matches a known release
- [ ] `CHANGELOG.md` — entries match actual changes in git history

### Agent Configuration

- [ ] `AGENTS.md` — no HTML comment placeholders remaining
- [ ] `AGENTS.md` — Code Style section references existing patterns (not just template defaults)
- [ ] `AGENTS.md` — Module size guidelines have concrete values (not `<!-- e.g. -->` placeholders)

### Markdown Links

- [ ] All relative `[links](./CHANGELOG.md)` in `.md` files resolve to actual files
- [ ] All cross-references (`[Foo](./ADOPTING.md)`) work within the repo

### What "Passing" Looks Like

```
$ .omp/skills/template-guide/scripts/audit.sh
Checking AGENTS.md for placeholders... PASS: no placeholders found
Checking required files... PASS: all required files present
Checking CI workflows... PASS: all workflow files present
Checking .template-version... PASS: version matches known release (0.5.0)
Checking markdown internal links... PASS: all links resolve
```

### What "Failing" Looks Like

```
$ .omp/skills/template-guide/scripts/audit.sh
Checking AGENTS.md for placeholders... FAIL: 3 placeholders remaining at lines 10, 14, 47
Checking .template-version... PASS: version matches known release (0.5.0)
Checking markdown internal links... FAIL: docs/ci.md links to missing ./docs/nonexistent.md
```

Run the audit after any significant change to confirm the project remains compliant.

## Upgrade Procedure

When a user wants to update their project to a newer template version:

1. **Check current version**: Read `.template-version` in the project and compare against `TheSmuks/ai-project-template`'s latest version
2. **Read the changelog**: Show them the CHANGELOG.md entries between their version and the latest
3. **Diff the files**: Identify which files changed and categorize by merge strategy (safe-to-copy, merge-carefully, never-overwrite)
4. **Walk through the merge**: Guide them through [UPGRADING.md](./UPGRADING.md)'s merge process
5. **Verify**: Run `audit.sh` after merging to confirm compliance

For the full upgrade guide, see [UPGRADING.md](./UPGRADING.md).

## Audit Script Usage

```bash
# Run the full compliance audit
.omp/skills/template-guide/scripts/audit.sh

# Run from any directory in the repo
cd /path/to/project
/path/to/.omp/skills/template-guide/scripts/audit.sh

# Expected output: pass/fail per check with line numbers for failures
```

The script checks:
1. No HTML comment placeholders in AGENTS.md
2. Required files exist (CHANGELOG.md, CONTRIBUTING.md, AGENTS.md, README.md)
3. CI workflow files present and not empty
4. `.template-version` exists and matches a known release
5. Internal markdown links resolve (relative links in `.md` files)

## For AI Agents

When working in a project scaffolded from this template:

- Read `AGENTS.md` first — it defines the conventions, commands, and project structure
- Before editing any file, read it fully — context determines correct changes
- Before renaming a symbol, find all references (`lsp references` or `grep`)
- Every PR must go through CI: `commit-lint`, `changelog-check`, `blob-size-policy`
- Always create PRs for changes — never push directly to `main`
- Use the audit script to verify compliance after major changes
