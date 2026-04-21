# Setup Guide for AI Agents

This document guides an AI agent (or human) through customizing the `ai-project-template` into a real project. If you just cloned this template, start here.

## What This Template Is

This is a **scaffolding structure**, not a project. Most files contain HTML-comment placeholders (`<!-- ... -->`) that must be filled in with project-specific values. The template provides:

- Directory structure conventions
- CI/CD workflows (commit linting, changelog enforcement, blob-size policy)
- Agent configuration framework (`.omp/agents/`)
- Documentation templates (AGENTS.md, ARCHITECTURE.md, CHANGELOG.md)
- Code quality thresholds (`.architecture.yml`)

## Required Information

Before starting setup, collect (ask or infer) the following:

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
| Key dependencies | Express, Zod, etc. | ARCHITECTURE.md |
| Source directory | `src/` | AGENTS.md, CODEOWNERS |
| Test directory | `tests/` | AGENTS.md |
| Architecture decisions | Any initial decisions | `docs/decisions/` |
| Default owner/team | `@org/team` | CODEOWNERS |

## Setup Checklist

Complete these steps in order. Mark each as done.

### 1. Fill in AGENTS.md

Replace every `<!-- ... -->` placeholder:

- **Project Overview**: Name, description, primary language
- **Build & Run**: Remove unused commands, fill in actual commands
- **Code Style**: Add language-specific style rules (max line length, naming conventions)
- **Module and File Size Guidelines**: Set concrete numbers in the table (remove `<!-- -->` placeholders)
- **Project Structure**: Replace the example with your actual directory layout
- **Testing**: Add test runner details, coverage expectations, how to run specific tests
- **Error Handling**: Customize error handling conventions for your language/framework

### 2. Fill in README.md

Replace the template content with:
- Project name and description
- Installation instructions
- Usage examples
- Link to CONTRIBUTING.md
- License information

### 3. Fill in ARCHITECTURE.md

Replace the placeholder with:
- High-level architecture overview
- Key components and their responsibilities
- Data flow diagram or description
- Dependency list with versions
- Deployment architecture (if applicable)

### 4. Create Language-Specific Files

Add the package manifest for your language:

| Language | Files to add |
|----------|-------------|
| TypeScript | `package.json`, `tsconfig.json` |
| Python | `pyproject.toml` or `requirements.txt` |
| Go | `go.mod` |
| Rust | `Cargo.toml` |

Also add language-specific config:
- Linter config (`.eslintrc`, `ruff.toml`, etc.)
- Formatter config (`.prettierrc`, etc.)
- Language server config if needed

### 5. Update .github/workflows/ci.yml

The CI workflow has a `test` job with placeholder commands. Update:
- Add your install/build/test steps
- Set the correct runtime version (Node, Python, Go, Rust)
- Add any additional CI jobs your project needs

### 6. Update .architecture.yml

Replace placeholder values with project-specific thresholds:
- Set `max_file_lines` to your convention
- Set `max_function_lines` to your convention
- Set `max_exports` to your convention
- Adjust `ignore_patterns` for your project structure

### 7. Update .devcontainer/devcontainer.json

- Set the correct base image for your language/runtime
- Add language-specific extensions
- Update features (e.g., Python, Go, Rust instead of Node)
- Remove if the project won't use devcontainers

### 8. Update CODEOWNERS

- Replace `@org/project-team` with the actual owner/team
- Add code owners for specific directories
- Remove sections that don't apply to your project

### 9. Update .gitignore

Add language-specific ignore patterns:
- Node: `node_modules/`, `dist/`, `.next/`
- Python: `__pycache__/`, `.venv/`, `*.egg-info/`
- Go: Binary output
- Rust: `target/`

### 10. Review .omp/agents/

The template includes three example agents:

| Agent | Purpose | Keep if... |
|-------|---------|------------|
| `code-reviewer.md` | Reviews staged changes for correctness, security, performance | You want automated PR reviews |
| `adr-writer.md` | Generates Architecture Decision Records | You want to track architectural decisions |
| `changelog-updater.md` | Updates CHANGELOG.md following Keep a Changelog | You use CHANGELOG.md actively |

For each example agent:
- **Keep** if it matches your workflow — customize its instructions for your project
- **Remove** if it doesn't apply
- **Add** new agents specific to your project (e.g., `deploy-agent.md`, `db-migration-agent.md`)

Agent files use the OMP agent format. Each has:
- `name`: How to invoke the agent
- `description`: What it does (shown in agent listings)
- `instructions`: The prompt the agent follows

### 11. Create docs/decisions/0001-initial-architecture.md

Use the ADR template at `docs/decisions/0000-template.md` to write your first Architecture Decision Record documenting the initial technology choices and architecture.

## Files to Remove

Remove these if they don't apply:

| File | Remove when... |
|------|---------------|
| `.omp/` entire directory | Not using Oh My Pi or any agent framework |
| `.devcontainer/` | Not using GitHub Codespaces or VS Code devcontainers |
| `docs/decisions/` | Not using ADRs (reconsider — ADRs are lightweight and valuable) |
| `.architecture.yml` | Not using automated code quality checks |

## Quality Gates

Before considering setup complete, verify:

- [ ] `AGENTS.md` has zero `<!-- -->` placeholders remaining
- [ ] `README.md` describes the actual project, not the template
- [ ] `ARCHITECTURE.md` describes the actual architecture
- [ ] CI workflow runs: `commit-lint`, `changelog-check`, `blob-size-policy` pass
- [ ] Test job in CI runs the actual test suite
- [ ] `.architecture.yml` has concrete values, not placeholders
- [ ] `CODEOWNERS` has real owner entries
- [ ] `.gitignore` covers the project's language and tooling
- [ ] Language-specific manifest (`package.json`, `Cargo.toml`, etc.) exists
- [ ] First ADR in `docs/decisions/` documents initial architecture
- [ ] `SETUP_GUIDE.md` is deleted (it served its purpose) or archived

## What Comes Next

After setup:
1. Delete this `SETUP_GUIDE.md` file — it has served its purpose
2. Create the initial commit on `main` with all customized files
3. Push to the remote repository
4. Verify all CI checks pass
5. Start building
