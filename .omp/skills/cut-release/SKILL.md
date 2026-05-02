---
name: cut-release
description: Cut a clean release — bump versions across all files, update changelog, create GitHub release
category: workflow
tags: [release, versioning, semver, automation]
version: 1.0.0
---

# Cut Release

Automated release workflow: determine version → delegate to cut-release.sh → commit → create PR → merge → publish GitHub release.

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

## Phase 1: Determine Version (You do this)

1. **Read current version** from `.template-version`:
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

## Phase 2: Execute Release (cut-release.sh does this)

Run the automation script with the version bump:

```bash
bash .omp/skills/cut-release/scripts/cut-release.sh <OLD_VERSION> <NEW_VERSION>
```

**Example:**
```bash
bash .omp/skills/cut-release/scripts/cut-release.sh 0.5.0 0.6.0
```

### What the script does:

1. **Pre-flight**: Verifies OLD_VERSION exists in all 7 version manifest files. Aborts if any are missing (prevents wrong version being passed).
2. **Update files**: Replaces version in all manifest files:
   | File | Pattern |
   |------|---------|
   | `.template-version` | whole file content |
   | `README.md` | `template-vX.Y.Z` in badge |
   | `AGENTS.md` | `version **X.Y.Z**` |
   | `SETUP_GUIDE.md` | `` `X.Y.Z` `` |
   | `.omp/skills/template-guide/SKILL.md` | `(X.Y.Z)` in examples |
   | `.omp/skills/template-guide/scripts/audit.sh` | KNOWN list entry |
   | `CHANGELOG.md` | Creates new version section from Unreleased |

3. **Post-flight**: Verifies NEW_VERSION exists in all files and OLD_VERSION is gone.
4. **Audit**: Runs `audit.sh` — must pass before proceeding.

### Dry run mode:

```bash
bash .omp/skills/cut-release/scripts/cut-release.sh <OLD> <NEW> --dry-run
```

Shows what would change without making any modifications.

---

## Phase 3: Commit, PR, Merge, Tag, Release (You do this)

1. **Review changes**:
   ```bash
   git diff
   ```

2. **Commit**:
   ```bash
   git add -A
   git commit -m "chore: cut vX.Y.Z"
   ```

3. **Push branch**:
   ```bash
   git push -u origin HEAD
   ```

4. **Create PR** (or use `merge-to-main` skill):
   ```bash
   gh pr create --base main --title "chore: cut vX.Y.Z" --body "## Summary
   
   Cut release vX.Y.Z.
   
   ## Changes
   
   - Updated version references across all manifest files
   - CHANGELOG.md updated with release section
   
   ## Verification
   
   - audit.sh passes
   - No stale version references remain"
   ```

5. **Monitor CI and merge** when all checks pass:
   ```bash
   gh pr merge <pr-number> --squash
   ```

6. **Switch to main and pull**:
   ```bash
   git checkout main && git pull
   ```

7. **Create annotated tag**:
   ```bash
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   ```

8. **Push tag**:
   ```bash
   git push origin vX.Y.Z
   ```

9. **Create GitHub release**:
   ```bash
   gh release create vX.Y.Z --title "vX.Y.Z" --notes "<changelog-body>"
   ```
   
   The release body should be the changelog section for this version (everything between `## [X.Y.Z]` and the next `## [` or end of file).

---

## Phase 4: Verify

1. **Release exists and is not draft**:
   ```bash
   gh release list
   gh release view vX.Y.Z
   ```

2. **Release body matches CHANGELOG.md**:
   Compare `gh release view vX.Y.Z --json body --jq '.body'` with the corresponding section in `CHANGELOG.md`

3. **All manifest files contain the new version**:
   ```bash
   cat .template-version  # should show new version
   grep "vX.Y.Z" README.md  # should find badge
   ```

4. **No stale references to old version remain**:
   ```bash
   grep -rn "vOLD-VERSION" . --include='*.md' --include='*.sh'  # must be empty
   ```

---

## Edge Cases

| Situation | Handling |
|-----------|----------|
| Empty `[Unreleased]` section | Abort — nothing to release |
| Multiple version-like strings | Use anchored patterns (handled by script) |
| Tag already exists | Detect via `git tag -l vX.Y.Z` and abort |
| Wrong version passed | Pre-flight check catches missing OLD_VERSION |
| Audit fails after update | Script aborts; fix manually before committing |

---

## What This Skill Does NOT Do

- Does not write the code or features being released (those are your main tasks)
- Does not force-push or rewrite shared history
- Does not publish to package registries (npm, PyPI, crates.io, etc.)
- Does not auto-resolve merge conflicts
- Does not bypass branch protection or skip CI checks