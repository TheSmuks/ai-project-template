# Adopting ai-project-template Into an Existing Repository

This guide is for teams who already have a codebase and want to bring in the conventions, structure, and agent configuration from `ai-project-template` — without disrupting existing workflows.

> **If you just cloned this template to start a new project, you're in the wrong place.** See [SETUP_GUIDE.md](./SETUP_GUIDE.md) instead.

---

## Pre-flight Audit

Before copying anything in, audit the existing repository. Write down:

1. **Language and runtime** — What language(s), version(s), and runtime(s) does the project use?
2. **Build system** — How is it built? (`npm`, `cargo`, `go build`, `pip`, `make`, etc.)
3. **Existing conventions** — Does the repo already have an `AGENTS.md`, `.editorconfig`, linter config, or style guide? If so, what does it prescribe?
4. **CI/CD** — What pipelines exist? What checks already run?
5. **Team norms** — Branch naming, commit style, PR process. Are these documented anywhere?
6. **Existing documentation** — Is there a `README.md`, `CONTRIBUTING.md`, `ARCHITECTURE.md`, or `docs/` directory?

This audit determines what you adopt, what you skip, and what you adapt.

---

## What to Copy In

These files from the template provide value for any repository, regardless of language or framework:

| File / Directory | What it provides | Copy it? |
|-----------------|------------------|----------|
| `AGENTS.md` | Project context for AI coding agents | **Yes** — adapt to match existing code |
| `ARCHITECTURE.md` | System design documentation | **Yes** — fill from existing code |
| `CONTRIBUTING.md` | Contribution guidelines | **Yes** — align with existing process |
| `CHANGELOG.md` | Change history format | **Yes** — if not already using a changelog |
| `docs/decisions/` | Architecture Decision Records | **Yes** — start recording decisions |
| `.architecture.yml` | Code quality thresholds | **Yes** — set thresholds to match current state |
| `.omp/agents/` | Agent definitions | **Yes** — keep agents that match your workflow |
| `.github/workflows/ci.yml` | Lint, typecheck, test | **Maybe** — only if you want the template's CI checks |
| `.github/workflows/commit-lint.yml` | Enforce conventional commits | **Maybe** — independent of existing CI |
| `.github/workflows/changelog-check.yml` | Require changelog entries on PRs | **Maybe** — independent of existing CI |
| `.github/workflows/blob-size-policy.yml` | Reject large files in PRs | **Maybe** — independent of existing CI |
| `.devcontainer/` | Dev container config | **Maybe** — skip if you already have one |
| `CODEOWNERS` | Code ownership | **Maybe** — skip if you already have one |
| `SETUP_GUIDE.md` | Greenfield setup instructions | **No** — not relevant to existing projects |

---

## What to Adapt

These files require modification. Don't copy them verbatim — tailor them to the existing codebase.

### AGENTS.md

Instead of filling placeholders from scratch, **read the existing code and derive the values**:

- **Project Overview**: Use the name and description from the existing `README.md`.
- **Build & Run**: Copy the actual commands from `Makefile`, `package.json`, `Cargo.toml`, or CI config.
- **Code Style**: Document the conventions the codebase *already follows*, not aspirational ones. If the code uses 2-space indentation and the template says 4, use 2. The goal is that AI agents match existing practice.
- **Module and File Size Guidelines**: Measure the current codebase. Set thresholds that flag *outliers*, not the median. If most files are 300 lines but a few are 800, set the guideline at 500 and accept that existing outliers exist.
- **Project Structure**: Run `tree` or `find` on the existing repo. Document what's actually there.
- **Testing**: Copy the test runner command from CI. Note any coverage expectations that already exist.
- **Error Handling**: Read how the codebase handles errors today. Document that pattern, even if it's not ideal. You can improve it later, but agents need to know the current state.

### ARCHITECTURE.md

- Read the existing source tree and document what the system *actually does*.
- Map the major components and their dependencies.
- If an architecture doc already exists, merge it into the template format rather than replacing it.

### .architecture.yml

- Set `max_file_lines`, `max_function_lines`, and `max_exports` to values slightly above the current p95. This avoids a flood of violations on adoption day.
- Add `ignore_patterns` for any generated code, vendored dependencies, or legacy directories you're not ready to refactor.

### .omp/agents/

- Review each agent definition. Keep the ones that match your workflow.
- Customize the `instructions` field to reference your project's actual conventions, paths, and tooling.

---

## What to Skip

Don't introduce files that duplicate or conflict with existing infrastructure:

- **`.devcontainer/`** — If the project already has a dev container, keep the existing one.
- **`.github/workflows/`** — If CI is already configured, copy individual workflow files (`commit-lint.yml`, `changelog-check.yml`, `blob-size-policy.yml`) as separate files alongside your existing workflows instead of replacing them. They run independently.
- **`CODEOWNERS`** — If ownership is already defined, don't overwrite it.
- **`.gitignore`** — Merge new patterns into the existing file; don't replace it.
- **`SETUP_GUIDE.md`** — Not relevant to existing projects.

---

## Incremental Adoption Path

Adopt the template in stages to avoid disrupting the team:

### Phase 1: Documentation (no behavioral change)

1. Add `AGENTS.md` — adapted to the existing codebase
2. Add `ARCHITECTURE.md` — documenting the current architecture
3. Add `CONTRIBUTING.md` — if it doesn't exist
4. Add `CHANGELOG.md` — if it doesn't exist
5. Create `docs/decisions/` and write the first ADR documenting the adoption of this template

This phase has zero impact on CI, builds, or developer workflows. It only adds documentation.

### Phase 2: Agent configuration (affects AI-assisted development)

1. Add `.omp/agents/` — start with `code-reviewer.md`
2. Review and customize each agent's instructions
3. Verify agents pick up `AGENTS.md` by running a test interaction

This phase affects how AI agents behave but doesn't change CI or build outputs.

### Phase 3: Quality gates (affects CI)

1. Add `.architecture.yml` — set thresholds conservatively
2. Add commit lint check to CI
3. Add changelog check to CI
4. Add blob-size policy to CI
5. Update `.gitignore` with any missing patterns

For items 2–4, choose one of two approaches:

- **Separate workflow files** (recommended): Copy `commit-lint.yml`, `changelog-check.yml`, and `blob-size-policy.yml` from the template into `.github/workflows/`. They work independently of any existing CI.
- **Merge into existing workflow**: Copy the job definitions from these files into your existing `ci.yml`.

For the full CI architecture guide, see [docs/ci.md](./docs/ci.md).

This phase adds CI checks. Do it last so the team isn't blocked by quality gates before the documentation is in place.

---

## Conflict Resolution

When existing conventions clash with template defaults:

| Conflict | Resolution |
|----------|------------|
| Different commit style | Keep the existing style. Update `AGENTS.md` to document it. |
| Different branch naming | Keep the existing convention. Update `AGENTS.md`. |
| Different test runner | Use the existing test runner. Update `AGENTS.md` build commands. |
| No existing changelog | Adopt [Keep a Changelog](https://keepachangelog.com/) from the template. |
| No existing ADR process | Adopt the template's ADR format going forward. Don't retrofit old decisions. |
| Different code quality thresholds | Set thresholds to match current state first. Tighten incrementally. |

**General principle**: The existing codebase is the source of truth. The template provides structure for documenting and enforcing conventions — it doesn't dictate what those conventions must be.

---

## Verification

After adoption, verify:

- [ ] `AGENTS.md` accurately describes the existing codebase (no placeholders, no aspirational content)
- [ ] `ARCHITECTURE.md` documents the current architecture
- [ ] `CONTRIBUTING.md` reflects the actual contribution process
- [ ] Agent definitions in `.omp/agents/` reference correct paths and commands
- [ ] `.architecture.yml` thresholds are set above the current p95
- [ ] CI checks pass on the existing codebase with the new quality gates
- [ ] No duplicate or conflicting configuration files

---

## For AI Agents

When an AI agent encounters an existing repository that might benefit from this template, follow this protocol.

### Detecting Adoption Candidates

A project is an adoption candidate if it has source code (language manifests like `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`) but lacks structured conventions (no `AGENTS.md`, or a bare/minimal one).

### Exploration Checklist

Before proposing any changes, explore the repository systematically:

1. **Language and manifests** — Read `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, or equivalent. Identify language, version, dependencies, and available scripts.
2. **Existing CI** — Read `.github/workflows/` (or equivalent). Map existing jobs, triggers, caching, and quality gates.
3. **Documentation** — Read `README.md`, `CONTRIBUTING.md`, `docs/`. Understand existing conventions and how the team communicates.
4. **Style and linting** — Read `.editorconfig`, linter configs (`.eslintrc`, `ruff.toml`, etc.), formatter configs. These define the code style.
5. **Build and test commands** — Read `Makefile`, `justfile`, `scripts/`, or CI steps to discover how to build, test, and lint.
6. **Project structure** — List top-level directories (`src/`, `lib/`, `app/`, `tests/`, etc.) to understand the layout.

### Generating a Diff Report

After exploration, generate a report showing:
- **What the project has** vs. **what the template provides**
- Which template files would be new additions
- Which would replace or conflict with existing files
- Recommended adoption phase for each addition

Then walk the user through the Incremental Adoption Path described earlier in this document.


## References & Further Reading

- [architecture.md](https://architecture.md/) — Architecture-as-code specification
- [agentskills.io/specification](https://agentskills.io/specification) — Agent skills specification
- [agents.md](https://agents.md/) — AGENTS.md open format specification
- [Oh My Pi documentation](https://github.com/can1357/oh-my-pi/tree/main/docs) — Oh My Pi harness documentation
