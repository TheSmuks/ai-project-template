---
name: setup
description: Interactive project setup from the ai-project-template — replaces the static SETUP_GUIDE.md with a guided, multi-step workflow
category: setup
tags: [setup, initialization, template, onboarding]
version: 1.0.0
---

# Interactive Setup Skill

Guides the agent (or user) through project initialization from the `ai-project-template`. This skill replaces the static `SETUP_GUIDE.md` with an interactive, multi-step workflow that lets adopters select which features to include.

## When to Use

Invoke this skill when:
- Starting a new project from the `ai-project-template`
- Adopting template conventions into an existing project
- Running `/setup` in an OMP session for a new repo
- User says "set up this project" or "initialize from template"

## Prerequisites

Before running this skill:
1. Ensure you're in a git repository (initialized or about to be)
2. Verify you have write permissions to create files
3. Check `SETUP_GUIDE.md` and `ADOPTING.md` for reference details

## Feature Groups

The setup workflow operates on **opt-in feature groups**. Each group can be accepted or declined. The skill asks, doesn't assume.

|Group|Default|Includes|
|-----|-------|--------|
|[Core Docs](#core-docs)|On (required)|AGENTS.md, ARCHITECTURE.md, CONTRIBUTING.md, README.md, CHANGELOG.md|
|[CI Workflows](#ci-workflows)|On|commit-lint, changelog-check, blob-size-policy, ci.yml|
|[Agent Config](#agent-config)|On|.omp/agents/ (code-reviewer, adr-writer, changelog-updater)|
|[OMP Extensions](#omp-extensions)|On|.omp/rules/, .omp/hooks/, .omp/tools/|
|[OMP Skills](#omp-skills)|On|.omp/skills/ (cut-release, merge-to-main, template-guide)|
|[Dev Container](#dev-container)|Off|.devcontainer/ configuration|
|[Code Quality](#code-quality)|On|.editorconfig, code style thresholds|
|[ADR Process](#adr-process)|On|docs/decisions/, initial ADR template|
|[Git Ignore](#git-ignore)|On|Language-specific .gitignore patterns|
|[CODEOWNERS](#codeowners)|Off|CODEOWNERS file|

---

## Step 1: Detect Context

First, determine whether this is a **greenfield** setup (from template) or **existing repo** adoption.

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
  → Skip Step 2 (project info already exists)
ELSE IF greenfield from template:
  → Full interactive flow
  → Collect project info in Step 2
```

---

## Step 2: Collect Project Info

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

## Step 3: Feature Selection

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

Prompt: "Include CI quality gates?"

```
✓ .github/workflows/ci.yml          — Lint, test, typecheck
✓ .github/workflows/commit-lint.yml — Commit message enforcement
✓ .github/workflows/changelog-check.yml — CHANGELOG update enforcement
✓ .github/workflows/blob-size-policy.yml — File size limits
```

### Agent Config

Prompt: "Include which agent configurations?" (multi-select)

```
✓ Code Reviewer     — Reviews PRs for correctness, security, style
✓ ADR Writer        — Generates Architecture Decision Records
✓ Changelog Updater — Updates CHANGELOG.md on releases
```

### OMP Extensions

Prompt: "Include which OMP extensions?" (multi-select)

```
✓ Rules     — Convention enforcement (TTSR and scope-based)
✓ Hooks     — Pre/post lifecycle interceptors
✓ Tools     — Custom callable tools
```

See [docs/omp-extensions-guide.md](docs/omp-extensions-guide.md) for details.

### OMP Skills

Prompt: "Include which skills?" (multi-select)

```
✓ Cut Release     — Semantic version bumps and release PRs
✓ Merge to Main   — Safe merge with changelog consolidation
✓ Template Guide  — Template-specific guidance and audit
✓ Setup (this)    — Interactive setup workflow
```

### Dev Container

Prompt: "Include devcontainer configuration?"

```
✓ .devcontainer/devcontainer.json — VS Code Dev Container setup
✓ .devcontainer/Dockerfile        — Container build definition
```

Recommended for team environments or consistent developer experience.

### Code Quality

Prompt: "Include code quality configuration?"

```
✓ .editorconfig         — Consistent editor settings
✓ Code style thresholds — Line limits, nesting depth, function size
```

Adapted to detected language.

### ADR Process

Prompt: "Include ADR (Architecture Decision Record) process?"

```
✓ docs/decisions/               — Decision log directory
✓ docs/decisions/0000-template.md — Template for new ADRs
```

### Git Ignore

Prompt: "Include .gitignore?"

```
✓ .gitignore — Language-specific patterns for:
  - JavaScript/TypeScript: node_modules, build artifacts
  - Rust: target/, Cargo.lock
  - Go: vendor/, *.exe
  - Python: __pycache__, .venv/, *.pyc
```

### CODEOWNERS

Prompt: "Include CODEOWNERS file?"

```
✓ CODEOWNERS — GitHub team ownership for code review routing
```

Off by default (requires team configuration).

---

## Step 4: Generate Files

For each selected feature group:

1. **Copy from template** with placeholder substitution
2. **Customize for detected language** (CI commands, .gitignore patterns)
3. **Fill in collected project info** (name, language, commands)
4. **Validate generated files** against template specification

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

## Step 5: Verify

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

---

## Step 6: Cleanup

After successful setup:

1. **Remove SETUP_GUIDE.md** (if greenfield) — replaced by this skill
2. **Remove unselected features** — don't leave commented-out code
3. **Update .template-version** — record the template version used
4. **Create initial commit** — commit all generated files

### Final Status Report

Present to the user:

```
✅ Setup Complete

Project: <name>
Language: <language>
Template Version: <version>

Installed Features:
  • Core Docs (AGENTS.md, ARCHITECTURE.md, etc.)
  • CI Workflows (3 quality gates)
  • Agent Config (3 agents)
  • OMP Extensions (rules, hooks, tools)
  • OMP Skills (4 skills)
  • Code Quality
  • ADR Process
  • Git Ignore

Next Steps:
  1. Review and customize AGENTS.md for your project
  2. Fill in architecture details in ARCHITECTURE.md
  3. Run your first build command to verify setup
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
