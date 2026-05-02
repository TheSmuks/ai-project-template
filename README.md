# ai-project-template

<div align="center">

**Opinionated starter template for AI-assisted development projects.** Ships with agent-aware project structure, ready-made CI workflows, code quality thresholds, and documentation templates — everything you need to scaffold a well-behaved codebase that AI coding agents can navigate effectively.

[![Changelog](https://img.shields.io/badge/changelog-Keep%20a%20Changelog-blue.svg?style=flat-square)](./CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat-square)](./LICENSE)
[![Template](https://img.shields.io/badge/template-v0.5.0-blueviolet.svg?style=flat-square)](./.template-version)
[![Use this template](https://img.shields.io/badge/use%20this%20template-Deploy-green?logo=github&style=flat-square)](https://github.com/TheSmuks/ai-project-template/generate)

<a href="https://github.com/TheSmuks/ai-project-template/generate"><img src="https://img.shields.io/badge/-Use%20this%20template-2ea44f?style=for-the-badge" alt="Use this template" /></a>
<a href="./SETUP_GUIDE.md"><img src="https://img.shields.io/badge/-Read%20the%20Docs-21759b?style=for-the-badge&logo=readme" alt="Read the Docs" /></a>

</div>

## About

AI coding agents (OMP, Codex, Cursor, Aider, and others) excel at implementation but struggle with project-level context — conventions, structure, and intent. This template bridges that gap by baking best practices directly into the project skeleton. Ships with `AGENTS.md`, pre-configured CI, code quality thresholds, and documentation templates, so agents can contribute effectively from day one.

## Features

| | |
---|---:|
 **Agent-aware project structure** — Standardized layout with `AGENTS.md`, `SKILL.md` patterns, and agent skills integration. AI coding agents can navigate and contribute effectively from day one. | **Ready-made CI workflows** — Opinionated GitHub Actions pipelines for linting, type-checking, testing, commit linting, changelog enforcement, and file size policy — no configuration required. |
 **Code quality thresholds** — Module size guidelines, function length limits, nesting depth rules, and module export counts built into project documentation. Quality gates enforced by CI. | **Two adoption paths** — Designed for both greenfield projects (via `SETUP_GUIDE.md`) and existing repositories (via `ADOPTING.md`). Incrementally adopt only what you need. |
 **Devcontainer configuration** — Pre-configured `.devcontainer/` with everything in place for VS Code Dev Containers or GitHub Codespaces. | **Documentation templates** — `CHANGELOG.md`, `CONTRIBUTING.md`, `AGENTS.md`, `docs/architecture.md`, and `docs/agent-files-guide.md` included and pre-formatted. |
 **Conventional commit enforcement** — CI rejects commits that don't follow [Conventional Commits](https://www.conventionalcommits.org/). Branch naming follows [Conventional Branch](https://github.com/nickshanks347/conventional-branch). | **Tiger Style principles** — Built-in engineering guidelines for high-reliability systems: assertions, bounded operations, zero tech debt. |

## Getting Started

 New Project | Existing Project |
---|---:|
 Start fresh with a fully configured project. Follow [SETUP_GUIDE.md](./SETUP_GUIDE.md) to customize metadata, install dependencies, and configure your first CI run. | Integrate incrementally into an existing repository. Follow [ADOPTING.md](./ADOPTING.md) to merge conventions and CI workflows without breaking your current workflow. |
 <a href="./SETUP_GUIDE.md"><img src="https://img.shields.io/badge/-Setup%20Guide-2ea44f?style=flat-square" alt="Setup Guide" /></a> | <a href="./ADOPTING.md"><img src="https://img.shields.io/badge/-Adoption%20Guide-21759b?style=flat-square" alt="Adoption Guide" /></a> |

## What's Included

<details>
<summary>Full file listing</summary>

| File / Directory | Purpose |
|---|---|
| `AGENTS.md` | Project-level context for AI coding agents — tells agents how to behave in this repo |
| `SETUP_GUIDE.md` | Step-by-step setup instructions for new projects (greenfield) |
| `ADOPTING.md` | Incremental adoption guide for existing repositories |
| `CONTRIBUTING.md` | Development guidelines and commit conventions |
| `CHANGELOG.md` | Version history following [Keep a Changelog](https://keepachangelog.com/) |
| `.github/workflows/ci.yml` | Main CI pipeline: lint, typecheck, test |
| `.github/workflows/commit-lint.yml` | Enforces Conventional Commits on all PR commits |
| `.github/workflows/changelog-check.yml` | Ensures CHANGELOG.md is updated in every PR |
| `.github/workflows/blob-size-policy.yml` | Rejects oversized files (configurable thresholds) |
| `docs/architecture.md` | Architecture-as-code specification template |
| `docs/agent-files-guide.md` | Practical guide for writing AGENTS.md, ARCHITECTURE.md, and SKILL.md |
| `docs/ci.md` | CI/CD workflow documentation |
| `.devcontainer/` | DevContainer configuration for VS Code / Codespaces |
| `.omp/skills/template-guide/` | Template conventions skill for AI agents — navigate, audit, upgrade |
| `.omp/skills/merge-to-main/` | PR lifecycle skill — create PR, monitor CI, fix failures, merge when green |
| `.omp/skills/cut-release/` | Release cut skill — bump versions, update changelog, create GitHub release |
| `.template-version` | Current template version tag |
| `LICENSE` | MIT license |

</details>

## Documentation

- [SETUP_GUIDE.md](./SETUP_GUIDE.md) — Getting started for new projects
- [ADOPTING.md](./ADOPTING.md) — Incremental adoption for existing repos
- [UPGRADING.md](./UPGRADING.md) — Re-sync guide for upgrading from older template versions
- [CONTRIBUTING.md](./CONTRIBUTING.md) — Development guidelines
- [docs/architecture.md](./docs/architecture.md) — Architecture specification template
- [docs/agent-files-guide.md](./docs/agent-files-guide.md) — Guide for agent configuration files
- [docs/ci.md](./docs/ci.md) — CI/CD workflow documentation

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for development guidelines, commit conventions, and branch naming.

## License

MIT License. See [LICENSE](./LICENSE).