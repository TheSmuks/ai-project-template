---
name: setup
description: Interactive project setup from the ai-project-template — replaces the static SETUP_GUIDE.md with a guided, multi-step workflow
category: setup
template-version: 0.6.0
tags: [setup, initialization, template, onboarding]
version: 1.1.0
---

# Interactive Setup Skill

Guides the agent (or user) through project initialization from the `ai-project-template`. This skill replaces the static `SETUP_GUIDE.md` with an interactive, multi-step workflow that lets adopters select which features to include.

## When to Use

Invoke this skill when:
- Starting a new project from the `ai-project-template`
- Adopting template conventions into an existing project
- Running `/setup` in an OMP session for a new repo
- User says "set up this project" or "initialize from template"
- User pastes the bootstrap prompt: "Set up this project from the ai-project-template. Read SETUP_GUIDE.md and follow the interactive setup."

## One-Liner Trigger

When a user pastes this prompt, invoke this skill immediately:

```
Set up this project from the ai-project-template. Read SETUP_GUIDE.md and follow the interactive setup.
```

The skill will:
1. Read `SETUP_GUIDE.md` for structured guidance
2. Detect the context (greenfield vs existing repo)
3. Ask targeted questions about language, build tools, and features
4. Generate and customize files
5. Verify the setup
6. Present a post-setup orientation explaining what was installed

## Prerequisites

Before running this skill:
1. Ensure you're in a git repository (initialized or about to be)
2. Verify you have write permissions to create files
3. Read `SETUP_GUIDE.md` — it contains the authoritative step definitions

## Feature Groups

The setup workflow operates on **opt-in feature groups**. Each group can be accepted or declined. The skill asks, doesn't assume.

|Group|Default|Includes|
|-----|-------|--------|
|[Core Docs](#core-docs)|On (required)|AGENTS.md, ARCHITECTURE.md, CONTRIBUTING.md, README.md, CHANGELOG.md|
|[CI Workflows](#ci-workflows)|On|commit-lint, changelog-check, blob-size-policy, ci.yml, branch-lint|
|[Agent Config](#agent-config)|On|.omp/agents/ (code-reviewer, adr-writer, changelog-updater)|
|[OMP Extensions](#omp-extensions)|On|.omp/rules/, .omp/hooks/, .omp/tools/|
|[OMP Skills](#omp-skills)|On|.omp/skills/ (cut-release, merge-to-main, template-guide)|
|[Dev Container](#dev-container)|Off|.devcontainer/ configuration|
|[Code Quality](#code-quality)|On|.editorconfig, code style thresholds|
|[ADR Process](#adr-process)|On|docs/decisions/, initial ADR template|
|[Git Ignore](#git-ignore)|On|Language-specific .gitignore patterns|
|[CODEOWNERS](#codeowners)|Off|CODEOWNERS file|

---

## Step 0: Detect Context

**Goal:** Determine whether this is a greenfield setup (from template) or an existing repository adoption.

### Greenfield Detection

Check for these signals:
- Empty repository (no commits)
- `.template-version` file present
- Project name in current directory matches template pattern

### Existing Repo Detection

Check for these signals:
- `ADOPTING.md` exists and is relevant
- Existing `AGENTS.md` or project files
- `.git/` exists with commit history

### Action

```
IF existing repo with ADOPTING.md:
  → Use ADOPTING.md logic (simplified flow)
  → Skip Step 2 (project info already exists in the codebase)
ELSE IF greenfield from template:
  → Full interactive flow
  → Collect project info in Step 1
ELSE:
  → Prompt user: "Is this a new project from the template, or an existing project to adopt?"
```

---

## Step 1: Collect Project Info

If greenfield, gather the essential information. Ask the user or infer from existing files.

### Required Information

1. **Project Name**
   - Infer: `basename $(pwd)` or from `package.json` / `Cargo.toml`
   - Ask if not detectable

2. **Primary Language**
   - Infer: Detect from `package.json` (JavaScript/TypeScript), `Cargo.toml` (Rust), `go.mod` (Go), `*.py` (Python)
   - Ask if ambiguous or not detected

3. **Build Commands**
   - Infer: Read from existing manifest files
   - Ask for any not detected:
     - Install command
     - Build command
     - Test command
     - Lint command
     - Type check command (if applicable)

### Example Detection Script

```bash
# Detect language
if [ -f "package.json" ]; then
  echo "javascript"
elif [ -f "Cargo.toml" ]; then
  echo "rust"
elif [ -f "go.mod" ]; then
  echo "go"
elif [ -f "*.py" ]; then
  echo "python"
fi
```

---

## Step 2: Feature Selection

Present each feature group to the user with clear descriptions. Use `ask` with `multi: true` where appropriate.

### Core Docs

**Required** — always installed. These are the minimum for template compliance.

```
✓ AGENTS.md          — Project context, build commands, code style
✓ ARCHITECTURE.md    — System design (scaffold, fill in later)
✓ CONTRIBUTING.md    — Contribution guidelines
✓ README.md          — Project documentation
✓ CHANGELOG.md       — Version history (starts with [Unreleased])
```

### CI Workflows

> **Warning:** Skipping CI means no automated quality gates. Commits won't be checked for conventional format, CHANGELOG entries won't be enforced, and file sizes won't be limited.

```
✓ .github/workflows/ci.yml              — Lint, test, typecheck
✓ .github/workflows/commit-lint.yml     — Commit message enforcement
✓ .github/workflows/changelog-check.yml  — CHANGELOG update enforcement
✓ .github/workflows/blob-size-policy.yml — File size limits
✓ .github/workflows/branch-lint.yml     — Branch naming conventions
```

### Agent Config

Multi-select. Which agents do you want?

```
✓ Code Reviewer     — Reviews PRs for correctness, security, style
✓ ADR Writer        — Generates Architecture Decision Records
✓ Changelog Updater — Updates CHANGELOG.md on releases
```

### OMP Extensions

```
✓ Rules     — Convention enforcement (TTSR and scope-based)
✓ Hooks     — Pre/post lifecycle interceptors
✓ Tools     — Custom callable tools
```

See [docs/omp-extensions-guide.md](docs/omp-extensions-guide.md) for details.

### OMP Skills

Multi-select. Which skills do you want?

```
✓ Cut Release     — Semantic version bumps and release PRs
✓ Merge to Main   — Safe merge with changelog consolidation
✓ Template Guide  — Template-specific guidance and audit
✓ Setup (this)    — Interactive setup workflow
```

### Dev Container

```
✓ .devcontainer/devcontainer.json — VS Code Dev Container setup
✓ .devcontainer/Dockerfile        — Container build definition
```

Recommended for team environments or consistent developer experience.

### Code Quality

```
✓ .editorconfig         — Consistent editor settings
✓ Code style thresholds — Line limits, nesting depth, function size
```

Adapted to detected language.

### ADR Process

```
✓ docs/decisions/               — Decision log directory
✓ docs/decisions/0000-template.md — Template for new ADRs
```

### Git Ignore

```
✓ .gitignore — Language-specific patterns for:
  - JavaScript/TypeScript: node_modules, build artifacts
  - Rust: target/, Cargo.lock
  - Go: vendor/, *.exe
  - Python: __pycache__, .venv/, *.pyc
```

### CODEOWNERS

```
✓ CODEOWNERS — GitHub team ownership for code review routing
```

Off by default (requires team configuration).


## Step 3: Generate & Customize Files

For each selected feature group:

1. **Generate from template** with placeholder substitution (not verbatim copy)
2. **Customize for detected language** (CI commands, .gitignore patterns)
3. **Fill in collected project info** (name, language, commands)
4. **Validate generated files** against template specification

### Per-File Generation Rules

| File | Rule | Why |
|------|------|-----|
| `CHANGELOG.md` | **Start fresh** — begin with `[Unreleased]` only. Do not copy template version history. | Template version history is irrelevant noise for adopting projects. |
| `AGENTS.md` | **Derive from codebase** — infer project name from directory, language from manifest files, build commands from existing scripts. | Copying placeholder content leaves incomplete project context. |
| `README.md` | **Replace template text** — describe the actual project, not the template. | Template README is for reference, not publication. |
| `ARCHITECTURE.md` | **Use as scaffold** — keep structure, fill with actual architecture or explicit TODOs. | Architecture is project-specific. |
| `CONTRIBUTING.md` | **Adapt to project** — use template as style reference, reflect actual conventions. | Conventions vary by project. |
| `.gitignore` | **Start from language defaults** — generate fresh, don't copy template verbatim. | Template's gitignore may include irrelevant entries. |

### Placeholder Substitution Map


|Placeholder|Replacement|
|-----------|-----------|
|`{{PROJECT_NAME}}`|Detected or provided project name|
|`{{LANGUAGE}}`|Primary language|
|`{{BUILD_CMD}}`|Install command|
|`{{TEST_CMD}}`|Test command|
|`{{DATE}}`|Current date (ISO 8601)|
|`{{TEMPLATE_VERSION}}`|Current template version|

### Language-Specific Adaptations

#### JavaScript/TypeScript
- CI workflow: `npm install && npm run lint && npm test`
- .gitignore: `node_modules/`, `dist/`, `.env`
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

---

## Step 4: Verify

After generation, run the audit to confirm compliance:

```bash
bash .omp/skills/template-guide/scripts/audit.sh
```

### Expected Output

```
[PASS] file-structure: Required directories exist
[PASS] required-files: All required files present
[PASS] yaml-frontmatter: Agent files have valid frontmatter
[PASS] format: Files follow template format
```

### Handling Failures

If any checks fail:

1. **Review failure details** — audit output shows which check failed
2. **Fix manually** or re-run setup for that group
3. **Document issues** in a `SETUP_ISSUES.md` for future resolution

> **Do not proceed to Step 5 with known failures.** The cleanup step removes `SETUP_GUIDE.md`, which means the audit checklist goes with it. Fix issues now.

---


## Step 5: Cleanup & Scaffolding Removal (Required)


<critical>
After successful setup, you **MUST** remove scaffolding files that are no longer relevant. This step is **mandatory** — do not skip it.
</critical>

After successful setup, **remove scaffolding files** that are no longer relevant:

```bash
# Remove setup scaffolding (no longer needed after interactive setup)
rm -f SETUP_GUIDE.md ADOPTING.md UPGRADING.md
```

These files document the setup process for agents, but once setup is complete:
- `SETUP_GUIDE.md` is replaced by this interactive skill
- `ADOPTING.md` is not relevant for greenfield projects
- `UPGRADING.md` has no prior version to upgrade from

### Scaffolding Anti-Patterns

| ❌ **Do NOT** | ✅ **Do Instead** |
|----------|-------------|
| Copy `CHANGELOG.md` verbatim | Start with empty `[Unreleased]` section |
| Copy template `AGENTS.md` placeholders | Derive project info from actual codebase |
| Leave `SETUP_GUIDE.md` after setup | Remove all three scaffolding files as final step |
| Say "Copy from template" | Say "Generate from template" |
| Include placeholder HTML comments | Remove all placeholders or fill with actual content |
| Skip cleanup step | Make cleanup the final mandatory step |

### Placeholder Enforcement

The CI audit job (`ci.yml`) checks all `.md` files for HTML comment placeholders.

**Important:** The CI check excludes:
- `.omp/` — internal tooling (self-referential)
- `.github/PULL_REQUEST_TEMPLATE.md` — template with intentional examples
- `AGENTS.md` in the **template root** — has example placeholders

After adopting into a **new project**, you must:
1. **Remove all `<!-- ... -->` placeholders** from your project's AGENTS.md and other files
2. The CI check will then fail if you accidentally leave any placeholders

This ensures projects adopting the template don't inherit placeholder confusion.

### Cleanup Confirmation

Verify cleanup by running the audit:

```bash
bash .omp/skills/template-guide/scripts/audit.sh
```

The audit will warn if scaffolding files are still present after setup.

---

## Step 6: Post-Setup Orientation

**Goal:** Explain what was installed and why each piece matters. Present this to the user after setup completes.

### What Was Installed

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

## Step 7: Initial Commit

After cleanup, create the initial commit:

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

### Final Status Report

Present to the user:

```
✅ Setup Complete

Project: <name>
Language: <language>
Template Version: <version>

Installed Features:
  • Core Docs (AGENTS.md, ARCHITECTURE.md, etc.)
  • CI Workflows (5 quality gates including branch-lint)
  • Agent Config (3 agents)
  • OMP Extensions (rules, hooks, tools)
  • OMP Skills (4 skills including setup)
  • Pre-commit hooks (conventional commits)
  • Code Quality
  • ADR Process
  • Git Ignore

Next Steps:
  1. Review and customize AGENTS.md for your project
  2. Fill in architecture details in ARCHITECTURE.md
  3. Install pre-commit hooks: `pip install pre-commit && pre-commit install`
  4. Run your first build command to verify setup
```

---

## Edge Cases

### Empty Repository

If setting up in a fresh repo with no files:

1. Initialize git if not done: `git init`
2. Proceed with full feature selection
3. All defaults are reasonable for most projects

### Existing Files Conflict

If generated file would overwrite existing file:

1. Prompt user: "File exists. Overwrite, Merge, or Skip?"
2. **Overwrite**: Replace entirely (back up first)
3. **Merge**: Combine with manual resolution
4. **Skip**: Keep existing, skip this file

### Language Not Detected

If language detection fails:

1. Ask user directly: "What is your project's primary language?"
2. Provide options: JavaScript/TypeScript, Rust, Go, Python, Other
3. Store selection for language-specific adaptations

### Partial Setup

If user interrupts or selects "skip" for many features:

1. Complete what's selected
2. Log what was skipped
3. Suggest re-running setup for skipped features
4. Don't leave half-configured CI or broken imports

---

## References

- [SETUP_GUIDE.md](SETUP_GUIDE.md) — Static setup guide with detailed steps
- [ADOPTING.md](ADOPTING.md) — Existing project adoption guide
- [docs/omp-extensions-guide.md](docs/omp-extensions-guide.md) — OMP extension types reference
- [docs/agent-files-guide.md](docs/agent-files-guide.md) — AGENTS.md, ARCHITECTURE.md, SKILL.md guides

---

## Output Format

After running this skill, output a summary:

```markdown
## Setup Summary

| Item | Status |
|------|--------|
| Project Name | `<name>` |
| Language | `<language>` |
| Template Version | `<version>` |
| Features Installed | `<count>` |
| Audit Status | Pass/Fail |

### Installed Features
- Feature 1
- Feature 2

### Skipped Features
- Feature A (user declined)
- Feature B (conflicted with existing)

### Next Actions
1. Action item
2. Action item
```
