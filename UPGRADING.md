# Upgrading Your Project from ai-project-template

This guide helps you synchronize a project scaffolded from an older version of `ai-project-template` with a newer template release. It complements [ADOPTING.md](./ADOPTING.md), which covers first-time adoption.

> **ADOPTING.md vs. UPGRADING.md**: ADOPTING.md is for first-time adoption (bringing template conventions into a project that has never used the template). UPGRADING.md is for projects that already use the template and want to pick up changes from a newer template version.

---

## Step 1: Check Your Current Version

Read the `.template-version` file in your project root:

```bash
cat .template-version
```

Compare it against the template's current version (check the same file on `TheSmuks/ai-project-template`).

---

## Step 2: Read the Changelog

The [CHANGELOG.md](./CHANGELOG.md) lists every change in each template release. Read the entries between your current version and the latest to understand what changed and whether it affects your project.

Look for:
- **Added** — New files or features you may want
- **Changed** — Modifications to existing files you may have customized
- **Removed** — Files that may be obsolete in your project
- **Fixed** — Bug fixes in workflow files you may be using

---

## Step 3: Merge Changes

### Which Files to Overwrite

| Category | Files | Strategy |
|---|---|---|
| **Safe to copy** | `.github/workflows/*.yml` (except `ci.yml`), `.editorconfig`, `docs/ci.md`, `docs/agent-files-guide.md`, `docs/architecture.md`, `docs/decisions/*`, `.devcontainer/devcontainer.json`, `dependabot.yml`, `.gitattributes`, `CODEOWNERS` | Overwrite if you haven't modified them locally |
| **Merge carefully** | `AGENTS.md`, `CONTRIBUTING.md`, `.architecture.yml`, `CHANGELOG.md` | Diff and cherry-pick structural changes; preserve project-specific content |
| **Never overwrite** | `README.md`, `ARCHITECTURE.md`, any project-specific files | Read changelog for new sections to add manually |
| **New files** | Any file not present in your version | Copy if relevant to your project |

### Merge Process

```bash
# 1. Add the template as a remote (one-time)
git remote add template https://github.com/TheSmuks/ai-project-template.git

# 2. Fetch the latest template
git fetch template

# 3. Check what changed in a specific file
git diff template/v0.1.0 -- AGENTS.md   # compare against your version tag
git diff template/main -- AGENTS.md     # or against latest

# 4. Cherry-pick or merge the changes you need
git checkout --patch template/main -- path/to/file
```

### Conflict Resolution

When a file you customized conflicts with a template update:

1. **Read both versions** — understand what each side changed
2. **Preserve your project-specific content** — your values (project name, language, commands) are correct
3. **Accept the structural update** — if the template changed the format, adopt the new format while keeping your values
4. **Test after merging** — run `audit.sh` (see below) to verify compliance

---

## Step 4: Verify the Upgrade

After merging, verify your project still conforms to template conventions:

```bash
# If the template-guide skill is installed:
# Run the compliance audit from the skill directory
.omp/skills/template-guide/scripts/audit.sh

# Or run checks manually:
# 1. No HTML comment placeholders in AGENTS.md
grep -n '<!-- -->' AGENTS.md && echo "FAIL: placeholders remain" || echo "PASS: no placeholders"

# 2. Required files exist
for f in CHANGELOG.md CONTRIBUTING.md AGENTS.md; do
    [ -f "$f" ] && echo "PASS: $f exists" || echo "FAIL: $f missing"
done

# 3. CI workflow files are present and not placeholder-only
for f in ci.yml commit-lint.yml changelog-check.yml blob-size-policy.yml; do
    [ -f ".github/workflows/$f" ] && echo "PASS: $f exists" || echo "FAIL: $f missing"
done

# 4. Internal markdown links resolve
# Run from repo root — checks relative links in all .md files
find . -name '*.md' -type f | while read f; do
    grep -oE '\]\(\./[^)]+\)' "$f" | while read link; do
        target=$(echo "$link" | sed 's/](\.\//\.\//' | tr -d ')]')
        [ -e "$target" ] || echo "FAIL: $f links to missing $target"
    done
done
```

---

## File Categories Explained

### Safe to Copy

These files provide infrastructure (CI/CD, tooling, documentation) that doesn't contain project-specific content. You can safely overwrite them with newer template versions:

- **`.github/workflows/`** — CI pipelines. `ci.yml` requires customization; the others (`commit-lint.yml`, `changelog-check.yml`, `blob-size-policy.yml`) are generally safe to overwrite.
- **`.editorconfig`** — Editor settings, language-agnostic
- **`docs/ci.md`** — CI documentation, not project-specific
- **`docs/agent-files-guide.md`** — Template authoring guide
- **`docs/architecture.md`** — Architecture template
- **`docs/decisions/`** — ADR templates
- **`.devcontainer/devcontainer.json`** — Dev container config (replace base image if needed)
- **`dependabot.yml`** — Dependency update automation
- **`CODEOWNERS`** — Code ownership (replace `@org/team` if needed)
- **`.gitattributes`** — Git attributes

### Merge Carefully

These files contain both template structure and project-specific content. Diff before merging:

- **`AGENTS.md`** — Contains project metadata (name, language, commands). Preserve your values; accept format updates.
- **`CONTRIBUTING.md`** — Contains commit guidelines (safe to accept) and project-specific notes (preserve).
- **`.architecture.yml`** — Contains quality thresholds. Set your own values after merging the structure.
- **`CHANGELOG.md`** — Merge the `[Unreleased]` section from the new template into your changelog.

### Never Overwrite

These files are fully project-specific. Do not replace them — read the changelog for new sections to add manually:

- **`README.md`** — Your project's documentation
- **`ARCHITECTURE.md`** (root) — Your project's architecture

---

## What to Do If You Skipped Setup

If you adopted the template but never ran through [SETUP_GUIDE.md](./SETUP_GUIDE.md), your project may have placeholder content. Before upgrading:

1. Run through the Quality Gates checklist in SETUP_GUIDE.md
2. Replace all `<!-- -->` placeholders with real values
3. Verify `AGENTS.md`, `README.md`, and `ARCHITECTURE.md` describe your actual project
4. Then proceed with the upgrade process above

---

## Getting Help

If the upgrade process is unclear or encounters conflicts you can't resolve:

1. Check the [CHANGELOG.md](./CHANGELOG.md) for specifics on what changed
2. Read the updated [SETUP_GUIDE.md](./SETUP_GUIDE.md) for reference
3. Consult the [docs/agent-files-guide.md](./docs/agent-files-guide.md) for file format details
4. Open an issue on [TheSmuks/ai-project-template](https://github.com/TheSmuks/ai-project-template/issues) if you encounter a template bug

---

## References

- [CHANGELOG.md](./CHANGELOG.md) — Version history
- [ADOPTING.md](./ADOPTING.md) — First-time adoption guide
- [SETUP_GUIDE.md](./SETUP_GUIDE.md) — Greenfield setup reference
- [docs/agent-files-guide.md](./docs/agent-files-guide.md) — Template file authoring guide
- [Oh My Pi documentation](https://github.com/can1357/oh-my-pi/tree/main/docs) — Agent harness documentation
