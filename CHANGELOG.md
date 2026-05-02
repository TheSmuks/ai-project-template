# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]


## [0.5.0] — 2026-05-02

### Added

- `.omp/rules/no-placeholders.md` — TTSR rule to catch HTML comment placeholders in template files
- `.omp/rules/changelog-required.md` — Scope-based rule reminding agents to update CHANGELOG.md for user-facing changes
- `.omp/rules/conventional-commits.md` — TTSR rule enforcing conventional commit message format
- `.omp/hooks/pre/protect-main.ts` — Pre-hook blocking direct commits/pushes to protected branches (main, master)
- `.omp/hooks/post/template-compliance-hint.ts` — Post-hook logging audit hints after template-critical file changes
- `.omp/tools/template-audit/index.ts` — Custom tool wrapping audit.sh with structured output for agent consumption
- `.omp/skills/setup/SKILL.md` — Interactive setup skill with multi-step feature selection workflow
- `docs/omp-extensions-guide.md` — Decision guide covering all 6 OMP extension types with examples from this repo

### Changed

- `docs/agent-files-guide.md` — Added Section F: OMP Extensions cross-reference guide
- `docs/agent-files-guide.md` — Renumbered References to Section G
- Internal link paths fixed in documentation files (relative paths corrected)

## [0.4.0] — 2026-05-02

### Added

- `cut-release` skill (`.omp/skills/cut-release/SKILL.md`) — automated release workflow: determine version, update version manifest, validate, commit, create PR, merge, publish GitHub release

## [0.3.0] — 2026-05-02

### Added

- `merge-to-main` skill (`.omp/skills/merge-to-main/SKILL.md`) — automates PR lifecycle: create, monitor CI, fix failures, update checkboxes, merge
- `branch-cleanup.yml` workflow — auto-deletes feature branches after PR is merged

### Changed

- Rewrite `README.md` with template-specific content (replaces empty placeholders)
- Add "Use this template" badge
- `README.md` and `AGENTS.md` updated to mention `merge-to-main` skill

### Fixed

- `branch-cleanup.yml` — requires `contents: write` permission to delete branches via Git refs API

## [0.2.0] — 2026-05-01

### Added

- Split CI into separate workflow files (`ci.yml`, `commit-lint.yml`, `changelog-check.yml`, `blob-size-policy.yml`)
- `docs/ci.md` — CI architecture guide
- Agent exploration section in `ADOPTING.md`
- Template versioning via `.template-version`
- `permissions` and `concurrency` declarations on all workflows
- `docs/agent-files-guide.md` — Practical guide for writing AGENTS.md, ARCHITECTURE.md, and SKILL.md with concrete examples
- Tiger Style reference in AGENTS.md and cross-references in SETUP_GUIDE.md, ADOPTING.md, docs/architecture.md

### Changed

- Updated ADOPTING.md with Tiger Style incorporation requirement for AGENTS.md adaptation
- Updated checkout action to `@v6` in all workflows

### Fixed

- Fetch full history in `blob-size-policy.yml` so `origin/main` resolves
- Fix `stat` command order (Linux before macOS)
- Remove duplicate description field in `feature_request.yml`
- Remove `.omp/agents/.gitkeep` (replaced by example agents)

## [0.1.0] — 2026-04-21

### Added

- `AGENTS.md` for cross-agent project context
- `README.md` with template instructions
- `CHANGELOG.md` (Keep a Changelog format)
- `CONTRIBUTING.md` with conventions and commit guidelines
- `LICENSE` (MIT)
- `.editorconfig` and `.gitignore` for AI/LLM projects
- `.omp/` directory structure (settings, example agents, hooks, tools)
- GitHub issue templates (bug report, feature request), PR template, SECURITY.md
- Placeholder CI workflow with conventional commit linting
- `docs/architecture.md` and root `ARCHITECTURE.md` templates
- Template extension: enhanced `AGENTS.md` (error handling, module size, agent behavior sections)
- Three example agents in `.omp/agents/` (code-reviewer, adr-writer, changelog-updater)
- `CODEOWNERS`, `dependabot.yml`, `.gitattributes`, enhanced PR template
- `.devcontainer/devcontainer.json`
- `docs/decisions/` with ADR template
- `SETUP_GUIDE.md` — LLM bootstrap guide
- `.architecture.yml` code quality thresholds
- `blob-size-policy.yml` GitHub Actions workflow