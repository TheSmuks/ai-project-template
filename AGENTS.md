# Project Context

> **If this is a new project from the ai-project-template, read [SETUP_GUIDE.md](./SETUP_GUIDE.md) first.**
> **If you're integrating this into an existing project, read [ADOPTING.md](./ADOPTING.md) instead.**

This file is auto-discovered by AI coding agents (OMP, Codex, Cursor, Aider, Jules, VS Code, and others). It provides project-level context that guides agent behavior.

## Project Overview

<!-- Describe your project here. What does it do? What problem does it solve? -->

- **Name**: <!-- project name -->
- **Description**: <!-- one-line description -->
- **Primary Language**: <!-- e.g. Python 3.12, TypeScript 5.x, Go 1.22 -->

## Build & Run


- **Install pre-commit hooks:** `pip install pre-commit && pre-commit install`

<!-- Fill in the commands for your project. Remove what doesn't apply. -->

```bash
# Install dependencies

# Build

# Run

# Run tests

# Lint

# Type check
```

## Code Style

<!-- Define your conventions. Agents will follow these. -->

- Follow the existing patterns in the codebase
- Write descriptive commit messages (see CONTRIBUTING.md)
- Keep functions small and focused
- Add tests for new behavior
- Update CHANGELOG.md for user-facing changes
- Follow [Tiger Style](./docs/agent-files-guide.md#e-tiger-style-reference) principles: assertions, bounded operations, zero tech debt. See the guide for details.

### Module and File Size Guidelines

<!-- Adjust these thresholds to match your project's conventions. -->
<!-- These are guidelines, not hard limits — but exceeding them should prompt a review. -->

| Metric | Guideline | Action if exceeded |
|--------|-----------|-------------------|
| File length | <!-- e.g. 500 --> lines | Split into focused modules |
| Function/method length | <!-- e.g. 50 --> lines | Extract helpers |
| Module exports | <!-- e.g. 20 --> public symbols | Re-evaluate module boundary |
| Nesting depth | <!-- e.g. 4 --> levels | Flatten with early returns or extract |

When a file or function exceeds these guidelines:
1. Consider whether the code has multiple responsibilities
2. If yes, extract the secondary concern into its own module
3. If no, add a comment explaining why the length is justified

## Project Structure

<!-- Document key directories once your project takes shape. Example:

```
src/
  api/        # REST/GraphQL API handlers
  models/     # Data models and schemas
  services/   # Business logic
  utils/      # Shared utilities
tests/       # Test files mirroring src/ structure
docs/        # Project documentation
```

-->

## Testing

<!-- How to run tests, what coverage expectations exist, etc. -->

- All new features must include tests
- Bug fixes must include a regression test
- Run the full test suite before submitting a PR
- Tests should be deterministic: no reliance on external services, wall-clock time, or random state unless explicitly controlled
- Prefer integration tests over mocks — mocks invent behaviors that never happen in production

## Error Handling

<!-- Define how errors should be propagated and logged. -->

- **Do not suppress errors.** Catching an exception and continuing silently is a bug.
- **Errors must be distinguishable from success.** A function that returns plausible-looking output when it has failed has broken its contract with every caller.
- **Fail at the boundary.** Validate inputs at system edges (user input, network responses, file I/O). Trust internal code.
- **Wrap, don't expose.** When wrapping an error from a dependency, add context. The caller should understand *what* failed, not just that something did.
- **No lying.** If an operation partially fails, do not return a success result with some fields silently missing. Return an error or a structured result that preserves the truth.

## CI/CD

CI uses separate workflow files, one concern per file. See [docs/ci.md](./docs/ci.md) for the full guide.

| Workflow | Purpose |
|----------|--------|
| `ci.yml` | Lint, typecheck, test — project-specific jobs |
| `commit-lint.yml` | Conventional commit enforcement |
| `changelog-check.yml` | Changelog format validation (PRs only) |
| `blob-size-policy.yml` | Rejects oversized files (PRs only) |
| `branch-cleanup.yml` | Deletes merged feature branches |
| `branch-lint.yml` | Enforces branch naming conventions (PRs only) |

**Pre-commit hooks** run locally before commits are accepted:
```bash
pip install pre-commit && pre-commit install
```
This enforces conventional commit format at the commit-msg stage, catching non-conforming messages before they reach CI.

When adding new CI checks:
## Agent Behavior

When an AI agent is working in this repository:

Agents can invoke the `template-guide` skill (`.omp/skills/template-guide/SKILL.md`) to look up conventions, audit compliance, or get upgrade guidance. Agents can also invoke the `merge-to-main` skill (`.omp/skills/merge-to-main/SKILL.md`) to automate the PR lifecycle after completing feature work, and the `cut-release` skill (`.omp/skills/cut-release/SKILL.md`) to cut a new release with proper version bumping and GitHub release creation.

1. **Always create PRs for changes.** Do not push directly to `main`.
2. **Run available validation before requesting review.** Execute lint, type-check, and test commands before declaring work complete.
3. **Read before editing.** Read the full file or section before making changes — context above and below the match determines the correct edit.
4. **Check references before renaming.** Use `grep` or language-server tools to find every consumer of a symbol before changing it.
5. **One concern per change.** A PR should address one issue or feature. Do not bundle unrelated refactors.
6. **Update documentation in the same change.** If code behavior changes, update comments, doc strings, and relevant docs in the same commit.
7. **Preserve invariants.** If the codebase has patterns (error handling, logging, auth), follow them. Do not introduce a new pattern without removing the old one.
8. **Clean up after yourself.** Remove unused imports, dead code, and temporary files. A change should leave the codebase cleaner than it was found.


9. **Load setup skill for new projects.** When setting up or adopting this template, load the `setup` skill (`.omp/skills/setup/SKILL.md`) and follow its workflow — do not wing it.
10. **Clean up scaffolding after setup.** After setup completes, remove all scaffolding files (`SETUP_GUIDE.md`, `ADOPTING.md`, `UPGRADING.md`). These are template documentation, not project files.
## Conventions

### Commits

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`

### Branches

Follow [Conventional Branch](https://github.com/nickshanks347/conventional-branch) naming:

```
<type>/<short-description>
```

Examples: `feature/add-embeddings`, `fix/token-overflow`, `chore/update-deps`

### Changelog

Follow [Keep a Changelog](https://keepachangelog.com/). Update `CHANGELOG.md` under `[Unreleased]` for every user-facing change.

## Template Version

This project was generated from `ai-project-template` version **0.7.0**. See [`.template-version`](./.template-version) for the current release. Agents can read this file to determine which conventions and files to expect.

## References & Further Reading

- [architecture.md](https://architecture.md/) — Architecture-as-code specification
- [agentskills.io/specification](https://agentskills.io/specification) — Agent skills specification
- [agents.md](https://agents.md/) — AGENTS.md open format specification
- [Oh My Pi documentation](https://github.com/can1357/oh-my-pi/tree/main/docs) — OMP harness documentation
- [docs/agent-files-guide.md](./docs/agent-files-guide.md) — Practical guide for writing AGENTS.md, ARCHITECTURE.md, and SKILL.md
- [Tiger Style (TigerBeetle)](https://github.com/tigerbeetle/tigerbeetle/blob/main/docs/TIGER_STYLE.md) — Engineering principles for high-reliability systems