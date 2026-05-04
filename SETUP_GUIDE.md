# Setup Guide

## For Humans

> **Using an AI coding agent?** Paste this into your session:
>
> ```
> Set up this project from the ai-project-template. Read SETUP_GUIDE.md and follow the interactive setup.
> ```
>
> Your agent will read this guide, detect your environment, ask a few questions, and configure everything for you.

**Alternative (manual setup):** If you're not using an AI coding agent, follow the numbered steps in the [For LLM Agents](#for-llm-agents) section below. Every step has inputs, actions, and verification criteria so you can validate your progress at each stage.

---

## For LLM Agents

> **IMPORTANT:** Read this entire file before starting. Do not skip steps. Skipping leads to incomplete configuration that CI will catch but you won't notice until it's too late.

- [Prerequisites](#prerequisites)
- [Step 0: Detect Context](#step-0-detect-context)
- [Step 1: Collect Project Info](#step-1-collect-project-info)
- [Step 2: Feature Selection](#step-2-feature-selection)
- [Step 3: Generate & Customize Files](#step-3-generate--customize-files)
- [Step 4: Verify](#step-4-verify)
- [Step 5: Cleanup & Initial Commit](#step-5-cleanup--initial-commit)
- [Step 6: Post-Setup Orientation](#step-6-post-setup-orientation)
- [Warnings](#warnings)
- [Quality Gates](#quality-gates)

---

## Prerequisites

Before running setup:

1. **Ensure you're in a git repository** — initialized (`git init`) or cloned from the template
2. **Verify write permissions** — you need to create and modify files
3. **Check the template version** — see [`.template-version`](.template-version) for the current release (currently **0.6.0**)

---

## Step 0: Detect Context

**Goal:** Determine whether this is a greenfield setup (from template) or an existing repository adoption.

### Inputs

- Current directory contents
- Git state (`git rev-parse --is-inside-work-tree`, `git log --oneline -1`)
- Presence of `.template-version`, `ADOPTING.md`, existing `AGENTS.md`

### Action

```
IF .template-version exists AND no meaningful commit history:
  → Greenfield setup (from template)
  → Full interactive flow (Steps 1-6)
  → SETUP_GUIDE.md is the correct guide
ELIF ADOPTING.md exists AND existing AGENTS.md or commit history:
  → Existing repo adoption
  → Switch to ADOPTING.md logic
  → Skip Step 1 (project info already exists in the codebase)
ELSE:
  → Prompt user: "Is this a new project from the template, or an existing project to adopt?"
```

### Verification

Confirm context type and communicate it to the user before proceeding.

---

## Step 1: Collect Project Info

**Goal:** Gather the information needed to customize template files.

### Inputs

- Optional: existing `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`
- User answers to targeted questions

### Action

Collect these fields. Ask when not inferable:

| Field | Example | Where it goes |
|-------|---------|---------------|
| Project name | `my-api` | AGENTS.md, README.md, ARCHITECTURE.md |
| Description | "A REST API for..." | AGENTS.md, README.md |
| Primary language + version | `TypeScript 5.x` | AGENTS.md, devcontainer.json |
| Runtime version | `Node 22` | devcontainer.json, CI workflow |
| Install command | `npm install` | AGENTS.md, CI workflow |
| Build command | `npm run build` | AGENTS.md, CI workflow |
| Test command | `npm test` | AGENTS.md, CI workflow |
| Lint command | `npm run lint` | AGENTS.md, CI workflow |
| Type check command | `npx tsc --noEmit` | AGENTS.md |
| Source directory | `src/` | AGENTS.md, CODEOWNERS |
| Test directory | `tests/` | AGENTS.md |
| Default owner/team | `@org/team` | CODEOWNERS |

### Question Format

Use structured `ask` calls with clear options:

- Single-select for discrete choices (language, runtime)
- Multi-select for feature groups
- Free-text for name, description, and custom commands

### Verification

Repeat the collected info back to the user and confirm before proceeding.

---

## Step 2: Feature Selection

**Goal:** Present feature groups so the user can opt in or out of each one.

### Feature Groups

Present each group with a one-line description. Use `ask` with `multi: true` where appropriate. Defaults are noted.

|Group|Default|Includes|
|-----|-------|--------|
|[Core Docs](#core-docs)|On (required)|AGENTS.md, ARCHITECTURE.md, CONTRIBUTING.md, README.md, CHANGELOG.md|
|[CI Workflows](#ci-workflows)|On|commit-lint, changelog-check, blob-size-policy, ci.yml, branch-lint|
|[Agent Config](#agent-config)|On|.omp/agents/ (code-reviewer, adr-writer, changelog-updater)|
|[OMP Skills](#omp-skills)|On|.omp/skills/ (cut-release, merge-to-main, template-guide, setup)|
|[Dev Container](#dev-container)|Off|.devcontainer/ configuration|
|[Code Quality](#code-quality)|On|.editorconfig, code style thresholds|
|[ADR Process](#adr-process)|On|docs/decisions/, initial ADR template|
|[Git Ignore](#git-ignore)|On|Language-specific .gitignore patterns|
|[CODEOWNERS](#codeowners)|Off|CODEOWNERS file|

---

#### Core Docs

**Required** — always installed. These are the minimum for template compliance.

```
✓ AGENTS.md          — Project context, build commands, code style
✓ ARCHITECTURE.md    — System design (scaffold, fill in later)
✓ CONTRIBUTING.md    — Contribution guidelines
✓ README.md          — Project documentation
✓ CHANGELOG.md       — Version history (starts with [Unreleased])
```

---

#### CI Workflows

```
✓ .github/workflows/ci.yml              — Lint, test, typecheck
✓ .github/workflows/commit-lint.yml     — Commit message enforcement
✓ .github/workflows/changelog-check.yml — CHANGELOG update enforcement
✓ .github/workflows/blob-size-policy.yml — File size limits
✓ .github/workflows/branch-lint.yml    — Branch naming conventions
```

> **Warning:** Skipping CI means no automated quality gates. Commits won't be checked for conventional format, CHANGELOG entries won't be enforced, and file sizes won't be limited. The template's CI workflows are designed to be additive — they run independently of existing CI.

---

#### Agent Config

Multi-select. Which agents do you want?

```
✓ Code Reviewer     — Reviews PRs for correctness, security, style
✓ ADR Writer        — Generates Architecture Decision Records
✓ Changelog Updater — Updates CHANGELOG.md on releases
```

---

#### OMP Skills

Multi-select. Which skills do you want?

```
✓ Cut Release      — Semantic version bumps and release PRs
✓ Merge to Main    — Safe merge with changelog consolidation
✓ Template Guide   — Template-specific guidance and audit
✓ Setup (this)     — Interactive setup workflow
```

---

#### Dev Container

```
✓ .devcontainer/devcontainer.json — VS Code Dev Container setup
✓ .devcontainer/Dockerfile         — Container build definition
```

Recommended for team environments or consistent developer experience.

---

#### Code Quality

```
✓ .editorconfig         — Consistent editor settings
✓ Code style thresholds  — Line limits, nesting depth, function size
```

Adapted to detected language.

---

#### ADR Process

```
✓ docs/decisions/               — Decision log directory
✓ docs/decisions/0000-template.md — Template for new ADRs
```

---

#### Git Ignore

```
✓ .gitignore — Language-specific patterns for:
  - JavaScript/TypeScript: node_modules, build artifacts
  - Rust: target/, Cargo.lock
  - Go: vendor/, *.exe
  - Python: __pycache__, .venv/, *.pyc
```

---

#### CODEOWNERS

```
✓ CODEOWNERS — GitHub team ownership for code review routing
```

Off by default (requires team configuration).

---

## Step 3: Generate & Customize Files

**Goal:** For each selected feature group, generate the files with project-specific customization.

### Actions

For each selected group:

1. **Copy from template** with placeholder substitution
2. **Customize for detected language** (CI commands, .gitignore patterns)
3. **Fill in collected project info** (name, language, commands)
4. **Validate generated files** — check for any remaining `<!-- -->` placeholders

### Placeholder Substitution Map

|Placeholder|Replacement|
|-----------|-----------|
|`{{PROJECT_NAME}}`|Detected or provided project name|
|`{{DESCRIPTION}}`|Project description|
|`{{LANGUAGE}}`|Primary language + version|
|`{{RUNTIME}}`|Runtime version|
|`{{INSTALL_CMD}}`|Install command|
|`{{BUILD_CMD}}`|Build command|
|`{{TEST_CMD}}`|Test command|
|`{{LINT_CMD}}`|Lint command|
|`{{TYPE_CHECK_CMD}}`|Type check command|
|`{{SOURCE_DIR}}`|Source directory|
|`{{TEST_DIR}}`|Test directory|
|`{{OWNER}}`|Default owner/team|
|`{{DATE}}`|Current date (YYYY-MM-DD)|
|`{{TEMPLATE_VERSION}}`|Current template version|

### Language-Specific Adaptations

#### JavaScript/TypeScript

- CI workflow: `npm install && npm run lint && npm run typecheck && npm test`
- .gitignore: `node_modules/`, `dist/`, `.env`, `.next/`
- Dev container: Node.js base image

#### Rust

- CI workflow: `cargo fmt --check && cargo clippy && cargo test`
- .gitignore: `target/`, `Cargo.lock` (if library)

#### Go

- CI workflow: `go fmt ./... && go vet ./... && go test ./...`
- .gitignore: `vendor/`, `*.exe`

#### Python

- CI workflow: `python -m pytest && python -m mypy .`
- .gitignore: `__pycache__/`, `.venv/`, `*.pyc`

### Verification

After generation, run the placeholder audit:

```bash
grep -r '<!-- ' --include='*.md' --exclude-dir='.omp' --exclude-dir='.github' .
```

Fix any remaining placeholders before proceeding.

---

## Step 4: Verify

**Goal:** Confirm the setup is correct before cleanup and commit.

### Audit Checklist

Run these checks in order. Mark each as pass/fail.

- [ ] `AGENTS.md` has zero `<!-- -->` placeholders remaining
- [ ] `README.md` describes the actual project, not the template
- [ ] `ARCHITECTURE.md` describes the actual architecture (or is scaffolded with explicit TODOs)
- [ ] CI workflow runs: `commit-lint`, `changelog-check`, `blob-size-policy` pass
- [ ] Test job in CI runs the actual test suite
- [ ] `.architecture.yml` has concrete values, not placeholders
- [ ] `CODEOWNERS` has real owner entries (or was skipped intentionally)
- [ ] `.gitignore` covers the project's language and tooling
- [ ] Language-specific manifest (`package.json`, `Cargo.toml`, etc.) exists
- [ ] First ADR in `docs/decisions/` documents initial architecture (or directory is skipped)

### Action on Failure

If any check fails:

1. **Review failure details** — identify which check failed and why
2. **Fix manually** — address the specific issue
3. **Re-verify** — re-run the checklist for that item
4. **Document unresolved issues** — in `SETUP_ISSUES.md` for future resolution

> **Do not proceed to Step 5 with known failures.** The cleanup step removes `SETUP_GUIDE.md`, which means the audit checklist goes with it. Fix issues now.

---

## Step 5: Cleanup & Initial Commit

**Goal:** Remove scaffolding files and commit the configured project.

### Remove Scaffolding Files

These files served their purpose during setup. Remove them:

```bash
rm -f SETUP_GUIDE.md ADOPTING.md
```

> **Do not remove `SETUP_GUIDE.md` before verifying Step 4.** Once removed, the audit checklist is gone too.

### Install Pre-commit Hooks

```bash
pip install pre-commit && pre-commit install
```

This runs on every `git commit` and will reject non-conforming commit messages before they reach CI.

### Create Initial Commit

```
git add -A
git commit -m "feat: initial project setup

Setup from ai-project-template v${TEMPLATE_VERSION}

Includes:
- Core documentation (AGENTS.md, ARCHITECTURE.md, CONTRIBUTING.md, README.md, CHANGELOG.md)
- CI workflows (ci.yml, commit-lint.yml, changelog-check.yml, blob-size-policy.yml, branch-lint.yml)
- Agent configuration (.omp/agents/, .omp/skills/)
- Pre-commit hooks (.pre-commit-config.yaml)
- OMP extensions (.omp/rules/, .omp/hooks/, .omp/tools/)
- Code Quality (.editorconfig, .architecture.yml)
- ADR Process (docs/decisions/)
- Git Ignore (language-specific patterns)

Skipped:
- Dev Container (not selected)
- CODEOWNERS (not selected)
"
```

---

## Step 6: Post-Setup Orientation

**Goal:** Explain what was installed and why each piece matters.

### What Was Installed

After setup completes, present this summary to the user:

#### Core Documentation

| File | Purpose | What to do with it |
|------|---------|-------------------|
| `AGENTS.md` | Project context for AI coding agents | Fill in project name, description, build commands, code style. AI agents read this on every session. |
| `ARCHITECTURE.md` | System design documentation | Document your architecture. Start with high-level overview, expand as you go. |
| `CONTRIBUTING.md` | Contribution guidelines | Document your commit style, branch naming, PR process. |
| `README.md` | Project documentation | Replace template content with actual project docs. |
| `CHANGELOG.md` | Version history | Every user-facing change goes here. See [Keep a Changelog](https://keepachangelog.com/). |

#### CI Workflows

| File | Purpose | Notes |
|------|---------|-------|
| `.github/workflows/ci.yml` | Lint, typecheck, test | Main CI pipeline. Customize with your actual commands. |
| `.github/workflows/commit-lint.yml` | Enforce conventional commits | Runs on every PR commit. No configuration needed. |
| `.github/workflows/changelog-check.yml` | Require changelog entries on PRs | Ensures every PR updates CHANGELOG.md. |
| `.github/workflows/branch-lint.yml` | Enforce branch naming conventions | Follows `<type>/<short-description>` pattern. |
| `.github/workflows/blob-size-policy.yml` | Reject files over 1MB | Adjust `BLOB_SIZE_LIMIT` if needed. |

#### Agent Configuration

| File | Purpose | When to use |
|------|---------|-------------|
| `.omp/agents/code-reviewer.md` | Reviews PRs for correctness, security, style | Invoke on any PR before merge. |
| `.omp/agents/adr-writer.md` | Generates Architecture Decision Records | Use when making significant architectural decisions. |
| `.omp/agents/changelog-updater.md` | Updates CHANGELOG.md | Use before releases or when merging significant features. |

#### OMP Skills

| Skill | Purpose | How to invoke |
|-------|---------|---------------|
| `cut-release` | Semantic version bumps, changelog, GitHub release | Run before each release. |
| `merge-to-main` | Monitor CI, fix failures, merge when green | Run after opening a PR. |
| `template-guide` | Navigate template conventions, audit compliance | Run when upgrading template versions. |
| `setup` | Interactive project setup | Re-run if you need to add features later. |

#### Code Quality

| File | Purpose | What to customize |
|------|---------|-------------------|
| `.editorconfig` | Consistent editor settings | Adjust for your team's preferences. |
| `.architecture.yml` | Code quality thresholds | Set concrete numbers based on your conventions. |

### Why These Matter

- **`AGENTS.md`** — Without it, AI agents make generic contributions that don't match your project's conventions. With it, they understand your build commands, code style, and project structure from day one.

- **CI workflows** — These are the quality gates that run on every PR. They catch conventional commit violations, missing changelog entries, oversized files, and branch naming issues before they reach `main`.

- **Agent configs** — AI agents have context windows that forget details. Agent definitions provide persistent, scoped instructions that apply whenever that agent is invoked.

- **OMP skills** — Skills provide structured workflows for complex, multi-step tasks. They encode best practices (audit before commit, consolidate changelogs before merge) so you don't have to remember the steps.

### Next Steps

1. **Review and customize `AGENTS.md`** — This is the most important file for AI-assisted development
2. **Fill in `ARCHITECTURE.md`** — Start with high-level overview, expand as the project evolves
3. **Configure your CI secrets** — Add any required secrets to GitHub
4. **Run your first build** — `npm run build` (or equivalent) to verify the project builds
5. **Make your first commit** — Follow conventional commit format: `feat:`, `fix:`, `docs:`, etc.

---

## Warnings

### Skipping CI

> **Warning:** Skipping CI means no automated quality gates. Commits won't be checked for conventional format, CHANGELOG entries won't be enforced, and file sizes won't be limited.

The template's CI workflows are designed to be additive — they run independently of existing CI. Even if you have your own CI, adding these workflows costs nothing and catches issues your CI might miss.

### Leaving Placeholders

> **Warning:** Leaving `<!-- ... -->` placeholders in project files causes audit failures. The CI `blob-size-policy.yml` workflow checks all `.md` files for HTML comment placeholders and will fail your PR if any are found.

The only files exempt from this check are:
- `.omp/` — internal tooling (self-referential)
- `.github/PULL_REQUEST_TEMPLATE.md` — template with intentional examples
- `AGENTS.md` in the **template root** — has example placeholders for reference

### Not Running Pre-commit Hooks

> **Warning:** Without pre-commit hooks, non-conforming commit messages reach CI and get rejected there. This means wasted CI minutes and delayed PRs.

Install them: `pip install pre-commit && pre-commit install`

### Skipping Documentation

> **Warning:** Skipping `AGENTS.md` or `ARCHITECTURE.md` means AI agents have no project context. They will make generic contributions that don't match your conventions, naming, or structure.

At minimum, keep these core docs even if you skip everything else.

---

## Quality Gates

Before considering setup complete, verify:

- [ ] `AGENTS.md` has zero `<!-- -->` placeholders remaining
- [ ] `README.md` describes the actual project, not the template
- [ ] `ARCHITECTURE.md` describes the actual architecture
- [ ] CI workflow runs: `commit-lint`, `changelog-check`, `blob-size-policy` pass
- [ ] Test job in CI runs the actual test suite
- [ ] `.architecture.yml` has concrete values, not placeholders
- [ ] `CODEOWNERS` has real owner entries (or was skipped intentionally)
- [ ] `.gitignore` covers the project's language and tooling
- [ ] Language-specific manifest (`package.json`, `Cargo.toml`, etc.) exists
- [ ] First ADR in `docs/decisions/` documents initial architecture (or directory is skipped)
- [ ] Pre-commit hooks are installed and functional

---

## References & Further Reading

- [architecture.md](https://architecture.md/) — Architecture-as-code specification
- [agentskills.io/specification](https://agentskills.io/specification) — Agent skills specification
- [agents.md](https://agents.md/) — AGENTS.md open format specification
- [Oh My Pi documentation](https://github.com/can1357/oh-my-pi/tree/main/docs) — OMP harness documentation
- [docs/agent-files-guide.md](./docs/agent-files-guide.md) — Practical guide for writing AGENTS.md, ARCHITECTURE.md, and SKILL.md

