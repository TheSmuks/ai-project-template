# CI Architecture Guide

## 1. Overview

This project uses separate GitHub Actions workflow files, one concern per file. Each workflow owns a single responsibility and can be enabled, disabled, or overridden independently.

| Workflow | Purpose |
|---|---|
| `ci.yml` | Lint, typecheck, and test |
| `commit-lint.yml` | Enforce conventional commit messages |
| `changelog-check.yml` | Require changelog entries on pull requests |
| `blob-size-policy.yml` | Reject large files in pull requests |

## 2. Workflow Structure

Separating workflows into individual files provides three advantages:

- **Independently disableable.** A failing commit-lint rule does not block test runs. You can disable a single workflow from the GitHub UI without editing YAML.
- **Overridable.** Teams can replace `ci.yml` with their own while keeping policy workflows intact.
- **Cacheable.** Each workflow maintains its own run history and cache scope, avoiding cross-contamination.

### Trigger model

```yaml
# ci.yml — lint, typecheck, test
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
```

```yaml
# commit-lint.yml — same triggers
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
```

```yaml
# changelog-check.yml — PRs only
on:
  pull_request:
    branches: [main]
```

```yaml
# blob-size-policy.yml — PRs only
on:
  pull_request:
    branches: [main]
```

Every workflow declares:

```yaml
permissions:
  contents: read

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

- **`permissions: contents: read`** — least-privilege default. No workflow can write to the repository unless explicitly granted.
- **`concurrency`** — cancels superseded runs for the same branch or PR, reducing queue time and resource consumption.

## 3. Caching Strategies

Dependency caching avoids re-downloading unchanged packages on every run. Configure per language.

### Node.js

```yaml
steps:
  - uses: actions/checkout@v6

  - uses: actions/setup-node@v4
    with:
      node-version: 20
      cache: npm

  - run: npm ci
```

`actions/setup-node` restores `~/.npm` keyed on `package-lock.json`. `npm ci` installs from the lockfile and skips resolution, making it the correct choice for CI.

### Python

```yaml
steps:
  - uses: actions/checkout@v6

  - uses: actions/setup-python@v5
    with:
      python-version: "3.12"
      cache: pip

  - run: pip install -r requirements.txt
```

`actions/setup-python` caches pip's download directory keyed on `requirements.txt` (or `pyproject.toml` if present).

### Go

```yaml
steps:
  - uses: actions/checkout@v6

  - uses: actions/setup-go@v5
    with:
      go-version: "1.22"

  - run: go build ./...
  - run: go test ./...
```

`actions/setup-go` caches `~/go/pkg/mod` and the build cache automatically. No extra configuration required.

### Rust

```yaml
steps:
  - uses: actions/checkout@v6

  - uses: actions/cache@v4
    with:
      path: |
        ~/.cargo/registry
        ~/.cargo/git
        target/
      key: cargo-${{ runner.os }}-${{ hashFiles('Cargo.lock') }}
      restore-keys: |
        cargo-${{ runner.os }}-

  - run: cargo build --locked
  - run: cargo test
```

Rust has no official setup action with built-in caching, so `actions/cache` is used directly. The key includes the OS and a hash of `Cargo.lock` to invalidate on dependency changes. The `restore-keys` prefix fallback avoids a cold cache when only `Cargo.lock` changed.

## 4. Parallelization

### Job dependencies with `needs`

Jobs run in parallel by default. Use `needs` to create a dependency graph:

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - run: npm run lint

  typecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - run: npm run typecheck

  test:
    needs: [lint, typecheck]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - run: npm test
```

`lint` and `typecheck` run in parallel. `test` starts only after both succeed. If either fails, `test` is skipped.

### Matrix builds for multi-version testing

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20, 22]
    steps:
      - uses: actions/checkout@v6

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: npm

      - run: npm ci
      - run: npm test
```

This creates three parallel jobs — one per Node version. Each job runs independently and all must pass for the workflow to succeed.

## 5. Reusable Workflows

### Calling workflows within the same repo

A workflow triggered by `workflow_call` can be invoked as a job:

```yaml
# .github/workflows/test.yml
on:
  workflow_call:
    inputs:
      node-version:
        required: false
        type: string
        default: "20"

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
          cache: npm
      - run: npm ci
      - run: npm test
```

```yaml
# .github/workflows/ci.yml — caller
jobs:
  test:
    uses: ./.github/workflows/test.yml
    with:
      node-version: "22"
```

### Sharing across repositories

```yaml
jobs:
  test:
    uses: my-org/shared-workflows/.github/workflows/test.yml@v1
    with:
      node-version: "22"
```

The `@ref` can be a tag, branch, or SHA. Tagged refs (`@v1`, `@v1.2.3`) are recommended for stability.

### Inputs and outputs

`workflow_call` accepts typed inputs (`string`, `boolean`, `number`, `choice`) and produces outputs:

```yaml
on:
  workflow_call:
    inputs:
      coverage-threshold:
        required: false
        type: number
        default: 80
    outputs:
      coverage-pct:
        description: "Measured coverage percentage"
        value: ${{ jobs.test.outputs.coverage-pct }}

jobs:
  test:
    runs-on: ubuntu-latest
    outputs:
      coverage-pct: ${{ steps.coverage.outputs.pct }}
    steps:
      - uses: actions/checkout@v6
      - run: npm ci
      - id: coverage
        run: echo "pct=$(npm run test:coverage --silent)" >> "$GITHUB_OUTPUT"
```

Callers read outputs from the job's `outputs` context: `${{ needs.test.outputs.coverage-pct }}`.

## 6. Adding Jobs

### Where to add new checks

- **Project-specific checks** (lint, test, coverage, deploy) → add jobs to `ci.yml`.
- **Cross-cutting policy** (commit style, changelog, file size limits) → create a separate workflow file.

### Example: adding a coverage job to `ci.yml`

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm run lint

  typecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm run typecheck

  test:
    needs: [lint, typecheck]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm test

  coverage:
    needs: [test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm run test:coverage
      - name: Enforce threshold
        run: npm run test:coverage -- --check-coverage --lines 80 --branches 80
```

The `coverage` job depends on `test`, keeping the gate order explicit: lint and typecheck in parallel, then test, then coverage.

## 7. Adoption — Merging Into Existing CI

### Option A: Add as separate workflow files

Copy the individual `.yml` files into `.github/workflows/`:

```
.github/workflows/ci.yml
.github/workflows/commit-lint.yml
.github/workflows/changelog-check.yml
.github/workflows/blob-size-policy.yml
```

These workflows run independently alongside any existing workflows. No conflicts, no integration effort. Remove them by deleting the files.

### Option B: Merge into an existing workflow

Copy the job definitions from each template workflow into your existing `ci.yml`. Then:

1. **Remove duplicate triggers.** If your existing workflow already triggers on `push` to `main` and `pull_request` to `main`, do not add the same triggers again. A single `on:` block covers everything.
2. **Merge `permissions`.** Use the union of required permissions. If your existing workflow needs `contents: write` for a deploy step, raise it:
   ```yaml
   permissions:
     contents: write
   ```
   Keep it as narrow as possible.
3. **Merge `concurrency`.** Use the same group pattern across all jobs to ensure superseded runs cancel correctly:
   ```yaml
   concurrency:
     group: ci-${{ github.ref }}
     cancel-in-progress: true
   ```
4. **Wire up `needs`.** If the imported jobs had no dependencies before, consider whether they should now depend on or be depended on by existing jobs.

## 8. Performance Tips

### Cancel superseded runs

The `concurrency` group in every workflow cancels older in-progress runs for the same ref:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

Pushing a new commit to a PR cancels the previous CI run, freeing runners immediately.

### Skip CI with commit messages

Include `[skip ci]` or `[ci skip]` in a commit message to prevent workflows from triggering:

```
docs: fix typo in README [skip ci]
```

GitHub Actions checks the commit message before creating workflow runs. Use this for documentation-only or cosmetic changes.

### Conditional steps

Run steps only when needed using `if`:

```yaml
- name: Deploy
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  run: npm run deploy
```

Common conditions:
- `github.event_name == 'pull_request'` — only on PRs
- `github.ref == 'refs/heads/main'` — only on main branch
- `success()` — only if all previous steps succeeded (default)
- `failure()` — only if a previous step failed (for notifications)

### Use shallow clones by default

```yaml
- uses: actions/checkout@v6
  # Default: fetch-depth 1 (shallow clone)
```

The default `fetch-depth` is `1`, which fetches only the latest commit. This is sufficient for most jobs.

Only use `fetch-depth: 0` (full history) when the job actually needs commit history, such as commit-lint:

```yaml
- uses: actions/checkout@v6
  with:
    fetch-depth: 0   # Required for commit-lint to inspect all commits
```

### Cache aggressively

Use specific cache keys to maximize hit rates:

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: npm-${{ runner.os }}-${{ hashFiles('package-lock.json') }}
    restore-keys: |
      npm-${{ runner.os }}-
```

The exact key (`hashFiles`) gives a cache hit on identical lockfiles. The prefix fallback (`restore-keys`) restores the most recent cache for the OS even when the lockfile changed, then `npm ci` fills in the diff.
