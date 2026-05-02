---
name: merge-to-main
description: Babysit a PR through CI — create, monitor, fix failures, merge when green
category: workflow
tags: [pr, ci, merge, automation]
version: 1.0.0
---

# Merge to Main

Automated PR lifecycle: prepare → create PR → monitor CI → fix failures → merge when green → update checkbox fields in the PR body.

## When to Use

Invoke this skill after completing work on a feature branch, when you are ready to create or update a pull request and merge it into `main`.

## Phase 1: Prepare

1. Read [`AGENTS.md`](./AGENTS.md) and [`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md) for conventions.
2. Verify the current branch follows `<type>/<short-description>` naming (e.g. `feature/add-embeddings`, `fix/token-overflow`).
3. Verify `CHANGELOG.md` has been updated under `[Unreleased]` (required by `changelog-check.yml`).
4. If the working tree is dirty, stage and commit remaining changes.
5. Push the branch to origin.

## Phase 2: Create PR

1. Read [`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md) if it exists.
2. Check whether a PR already exists for this branch:
   ```bash
   gh pr list --head <branch-name> --state open
   ```
   If one exists, skip creation and proceed to Phase 3.
3. Create the PR via `gh pr create`:
   ```bash
   gh pr create --base main --title "<title>" --body "<body>"
   ```
   - **Title**: Extract from the first line of the most recent commit message (conventional commit format: `<type>[optional scope]: <description>`).
   - **Body**: Fill in the PR template based on the changes. Leave "Automated checks" boxes unchecked — Phase 4 will update them.
   - **Draft**: Create as ready-for-review by default. Use `--draft` to create a draft PR instead.

## Phase 3: Monitor CI

1. Poll check status:
   ```bash
   gh pr checks <pr-number>
   ```
2. Wait for all checks to reach a terminal state (`pass` or `fail`).
   - **Poll interval**: ~30 seconds
   - **Max wait**: 10 minutes
3. For each failing check:
   a. Read the failure log:
       ```bash
       gh run view <run-id> --log-failed
       ```
   b. Diagnose the issue.
   c. Fix the issue using appropriate tools (read, edit, search, ast_edit).
   d. Amend the last commit (if unpushed) or create a new fix commit.
   e. Push the fix.
   f. Re-enter the monitoring loop.
4. **Max retries**: 3 (to prevent infinite loops on unfixable issues).
5. After 3 retries with failures, report what failed and stop — let the user decide.

### What to Fix

| Symptom | Likely fix |
|---|---|
| Lint failure | Read the linter output, fix the flagged code |
| Type check failure | Fix type mismatches or missing imports |
| Test failure | Fix the failing test or the code it exercises |
| Changelog check failure | Add an entry to `CHANGELOG.md` under `[Unreleased]` |
| Missing secrets | Report to user — requires human action |

## Phase 4: Update PR Body and Merge

1. Once all checks pass, read the current PR body:
   ```bash
   gh pr view <pr-number> --json body --jq '.body'
   ```
2. Update the PR body to check the "Automated checks" boxes:
   - `- [ ] CI passes` → `- [x] CI passes`
   - `- [ ] Test suite passes` → `- [x] Test suite passes`
3. Apply the updated body:
   ```bash
   gh pr edit <pr-number> --body "<updated-body>"
   ```
4. Merge the PR:
   - **Single clean commit**: `gh pr merge <pr-number> --merge`
   - **Many small fix commits**: `gh pr merge <pr-number> --squash`
5. Switch back to `main` and pull:
   ```bash
   git checkout main && git pull
   ```
6. Report success.

## Edge Cases

| Situation | Handling |
|---|---|
| Branch not pushed | Push it first (Phase 1) |
| PR already exists | Detect via `gh pr list --head <branch>` and reuse it |
| Merge conflict | Report to user — do not attempt auto-resolve |
| CI timeout (>10 min) | Report which checks are still pending |
| Unfixable failure (missing secrets, external outage) | Report and stop |
| Draft PR needed | Use `gh pr create --draft` instead of the default ready-for-review |
| Multiple commits on branch | Squash if many small fix commits; merge commit if single clean commit |

## What This Skill Does NOT Do

- Does not create the feature branch or write the code (those are the agent's main tasks).
- Does not force-push or rewrite shared history.
- Does not bypass branch protection or skip CI checks.
- Does not auto-resolve merge conflicts.
- Does not auto-resolve CI failures that require architectural decisions or human input.