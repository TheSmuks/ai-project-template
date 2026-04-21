# Project Context

This file is auto-discovered by AI coding agents (OMP, Codex, Cursor, Aider, Jules, VS Code, and others). It provides project-level context that guides agent behavior.

## Project Overview

<!-- Describe your project here. What does it do? What problem does it solve? -->

- **Name**: <!-- project name -->
- **Description**: <!-- one-line description -->
- **Primary Language**: <!-- e.g. Python 3.12, TypeScript 5.x, Go 1.22 -->

## Build & Run

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
