---
name: cut-release
description: Cut a clean release — bump versions across all files, update changelog, create GitHub release
category: workflow
tags: [release, versioning, semver, automation]
version: 1.0.0
---

# Cut Release

Automated release workflow: determine version → update version manifest → validate → commit → create PR → merge → publish GitHub release.

## When to Use

Invoke this skill whenever you are ready to cut a new release. Common triggers:
- After merging feature branches that warrant a version bump
- Before publishing a new skill or template version
- When `[Unreleased]` in `CHANGELOG.md` has accumulated changes worth releasing

## Prerequisites

- All work for this release is committed and pushed
- `CHANGELOG.md` has entries under `[Unreleased]`
- You have push access to the repository

---

## Phase 1: Determine Version

1. **Read current version** from `.template-version` (or project version file):
   ```bash
   cat .template-version
   ```

2. **Read changelog** to understand what has changed under `[Unreleased]`:
   ```bash
   head -30 CHANGELOG.md
   ```

3. **Compute next version** using semver:
   - `feat:` commits → **minor** bump (e.g. `1.2.0` → `1.3.0`)
   - `fix:` commits → **patch** bump (e.g. `1.2.0` → `1.2.1`)
   - `feat!:` or `BREAKING CHANGE` in body → **major** bump (e.g. `1.2.0` → `2.0.0`)

4. **Ask user to confirm or override** the computed version before proceeding.

> If `[Unreleased]` is empty, abort — nothing to release.

---

## Phase 2: Discover Version Manifest

### For the Template Repo

The following files carry the template version and must be updated on every release:

| # | File | Pattern | How to Update |
|---|------|---------|---------------|
| 1 | `.template-version` | Single line: `X.Y.Z` | Write new version |
| 2 | `CHANGELOG.md` | `## [Unreleased]` → `## [X.Y.Z] — YYYY-MM-DD` | Edit heading; insert new `[Unreleased]` |
| 3 | `README.md` | Badge URL: `template-vX.Y.Z` | Replace in badge image URL |
| 4 | `AGENTS.md` | `version **X.Y.Z**` | Replace version number |
| 5 | `SETUP_GUIDE.md` | `` `X.Y.Z` `` (template version line) | Replace version number |
| 6 | `.omp/skills/template-guide/SKILL.md` | Example output: `(X.Y.Z)` | Replace in audit output examples |
| 7 | `.omp/skills/template-guide/scripts/audit.sh` | `KNOWN="... X.Y.Z"` | Append new version to known list |

### For Template-Derived Repos

When working in a repo scaffolded from `ai-project-template`, the version manifest will differ. Follow these steps to discover and adapt:

**Step 1: Search for current version**
```bash
grep -rn "X.Y.Z" --include='*.md' --include='*.json' --include='*.toml' --include='*.yaml' --include='*.yml' --include='*.sh' --include='*.py' .
```

**Step 2: Classify common file types**

| File | Language/Tool | Pattern |
|------|---------------|---------|
| `package.json` | Node.js | `"version": "X.Y.Z"` |
| `Cargo.toml` | Rust | `version = "X.Y.Z"` |
| `pyproject.toml` | Python | `version = "X.Y.Z"` |
| `setup.py` / `setup.cfg` | Python | `version='X.Y.Z'` |
| `go.mod` | Go | `module ... vN` (major only) |
| `*.gemspec` | Ruby | `version = 'X.Y.Z'` |
| `pom.xml` / `build.gradle` | Java | `<version>X.Y.Z</version>` |
| `Chart.yaml` | Helm | `version: X.Y.Z` / `appVersion: X.Y.Z` |
| `Dockerfile` | Docker | Labels or ARGs with version |

Template-specific files (always present in template-derived repos):
- `.template-version` — template version (separate from project version)
- `CHANGELOG.md` — release history
- `README.md` — badges, installation instructions
- `AGENTS.md` — project metadata
- `audit.sh` — known versions list

**Step 3: Build the manifest**

For each file found in Step 1, record:
- File path
- The pattern that contains the version (for search/replace)
- Whether it's the project version or template version (they may differ)

**Step 4: Present the manifest to the user for review before proceeding.**

---

## Phase 3: Update Files

### For Each File in the Manifest

1. Search for the old version string
2. Replace with the new version
3. Verify the replacement (read the file back)

### For `CHANGELOG.md`

Replace `## [Unreleased]` with:
```
## [Unreleased]

## [X.Y.Z] — YYYY-MM-DD
```

- Keep the entries that were under `[Unreleased]` under the new version header
- Add a new empty `[Unreleased]` section at the top

### For `audit.sh` (if present)

Append the new version to the `KNOWN` string.

---

## Phase 4: Validate

1. Run `audit.sh` — must pass:
   ```bash
   .omp/skills/template-guide/scripts/audit.sh
   ```

2. Verify no stale version references remain:
   ```bash
   grep -rn "X.Y.Z" . --include='*.md' --include='*.sh' --include='*.yml'
   ```
   Must return zero hits for the old version in version-carrying contexts.

3. Verify `CHANGELOG.md` has both:
   - `[Unreleased]` (empty or with new entries)
   - `[X.Y.Z]` (with the released entries)

---

## Phase 5: Commit and PR

1. **Commit all version updates**:
   ```bash
   git add -A
   git commit -m "chore: cut vX.Y.Z"
   ```

2. **Push the branch**:
   ```bash
   git push -u origin HEAD
   ```

3. **Create PR**:
   ```bash
   gh pr create --base main --title "chore: cut vX.Y.Z" --body "## Summary

Cut release vX.Y.Z.

## Changes

- Updated version references across $(git diff --stat | tail -1)
- CHANGELOG.md updated with release section

## Verification

- audit.sh passes
- No stale version references remain"
   ```

4. **Babysit CI**: Monitor checks, fix any failures, push fixes, re-poll.

5. **Merge** when all checks pass:
   ```bash
   gh pr merge <pr-number> --squash
   ```

6. **Switch back to main**:
   ```bash
   git checkout main && git pull
   ```

---

## Phase 6: Create GitHub Release

1. **Create annotated tag**:
   ```bash
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   ```

2. **Push tag**:
   ```bash
   git push origin vX.Y.Z
   ```

3. **Create GitHub release**:
   ```bash
   gh release create vX.Y.Z --title "vX.Y.Z" --notes "<changelog-body>"
   ```
   
   The release body is the changelog section for this version (everything between `## [X.Y.Z]` and the next `## [` or end of file).

---

## Phase 7: Verify

1. Release exists and is not draft:
   ```bash
   gh release list
   gh release view vX.Y.Z
   ```

2. Release body matches `CHANGELOG.md`:
   - Compare `gh release view vX.Y.Z --json body --jq '.body'` with the corresponding section in `CHANGELOG.md`

3. All manifest files contain the new version:
   ```bash
   cat .template-version  # should show new version
   grep "vX.Y.Z" README.md  # should find badge
   ```

4. No stale references to old version remain:
   ```bash
   grep -rn "vOLD-VERSION" . --include='*.md' --include='*.sh'  # must be empty
   ```

---

## Edge Cases

| Situation | Handling |
|-----------|----------|
| Empty `[Unreleased]` section | Abort — nothing to release |
| Multiple version-like strings | Use anchored patterns, not blanket replace |
| Pre-release versions | Support `--prerelease` flag for alpha/beta/rc tags |
| Tag already exists | Detect via `git tag -l vX.Y.Z` and abort if found |
| Project vs template version differ | Keep them separate; only bump template version unless project also changed |
| Release PR CI fails | Diagnose and fix like any other PR (see `merge-to-main` skill) |

---

## What This Skill Does NOT Do

- Does not write the code or features being released (those are the agent's main tasks)
- Does not force-push or rewrite shared history
- Does not publish to package registries (npm, PyPI, crates.io, etc.)
- Does not auto-resolve merge conflicts
- Does not bypass branch protection or skip CI checks