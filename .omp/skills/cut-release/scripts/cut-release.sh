#!/usr/bin/env bash
# cut-release.sh — Automated version bump for ai-project-template
#
# Usage:
#   bash .omp/skills/cut-release/scripts/cut-release.sh <OLD_VERSION> <NEW_VERSION> [--dry-run]
#
# What this does:
#   - Validates inputs (versions differ, NEW is valid semver)
#   - Pre-flight: verifies OLD_VERSION exists in all manifest files
#   - Updates all 7 version manifest files
#   - Post-flight: verifies NEW_VERSION exists everywhere, OLD_VERSION is gone
#   - Runs audit.sh to confirm compliance
#   - Prints summary of changes
#
# What this does NOT do:
#   - Commit, push, create PR, merge, tag, or create GitHub release
#   - Handle CHANGELOG_BODY_FILE (reserved for future use)
#
set -euo pipefail

# ── Helpers ──────────────────────────────────────────────────────────────────

fatal() {
  echo "ERROR: $*" >&2
  exit 1
}

pass() { echo "[PASS] $*"; }
fail() { echo "[FAIL] $*" >&2; ERRORS=$((ERRORS + 1)); }

# ── Parse args ───────────────────────────────────────────────────────────────

DRY_RUN=false
REMAINING_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      REMAINING_ARGS+=("$1")
      shift
      ;;
  esac
done

set -- "${REMAINING_ARGS[@]}"
OLD_VERSION="${1:-}"
NEW_VERSION="${2:-}"

if [[ -z "$OLD_VERSION" ]] || [[ -z "$NEW_VERSION" ]]; then
  echo "Usage: $0 <OLD_VERSION> <NEW_VERSION> [--dry-run]"
  echo "  e.g.: $0 0.5.0 0.6.0"
  exit 1
fi

if [[ "$OLD_VERSION" == "$NEW_VERSION" ]]; then
  fatal "OLD_VERSION and NEW_VERSION must differ"
fi

# Validate semver format
SEMVER_REGEX='^[0-9]+\.[0-9]+\.[0-9]+$'
if ! echo "$NEW_VERSION" | grep -qE "$SEMVER_REGEX"; then
  fatal "NEW_VERSION must be valid semver (X.Y.Z): got '$NEW_VERSION'"
fi

# ── Version Manifest ─────────────────────────────────────────────────────────
# The 7 files that carry the template version and must be updated on every release.

MANIFEST=(
  ".template-version"
  "README.md"
  "AGENTS.md"
  "SETUP_GUIDE.md"
  ".omp/skills/template-guide/SKILL.md"
  ".omp/skills/template-guide/scripts/audit.sh"
  "CHANGELOG.md"
)

DATE_NOW=$(date +%Y-%m-%d)

# ── Dry-run mode ─────────────────────────────────────────────────────────────

if [[ "$DRY_RUN" == "true" ]]; then
  echo "=== DRY RUN: Would update version manifest from $OLD_VERSION to $NEW_VERSION ==="
  echo ""
  echo "Files that would be updated:"
  for file in "${MANIFEST[@]}"; do
    echo "  - $file"
  done
  echo ""
  echo "Dry-run complete. No files were modified."
  exit 0
fi

# ── Pre-flight: Verify OLD_VERSION exists in all manifest files ────────────

echo "=== Pre-flight: Verifying OLD_VERSION ($OLD_VERSION) in all manifest files ==="
ERRORS=0

for file in "${MANIFEST[@]}"; do
  if [[ ! -f "$file" ]]; then
    fail "$file does not exist"
    continue
  fi

  case "$file" in
    .template-version)
      if grep -q "^${OLD_VERSION}$" "$file"; then
        pass "$file contains OLD_VERSION"
      else
        fail "$file does not contain OLD_VERSION as exact version"
      fi
      ;;
    README.md)
      if grep -q "template-v${OLD_VERSION}" "$file"; then
        pass "$file references OLD_VERSION in badge"
      else
        fail "$file does not reference OLD_VERSION in badge"
      fi
      ;;
    AGENTS.md)
      if grep -q "version \*\*${OLD_VERSION}\*\*" "$file"; then
        pass "$file contains 'version **OLD_VERSION**'"
      else
        fail "$file does not contain 'version **OLD_VERSION**'"
      fi
      ;;
    SETUP_GUIDE.md)
      if grep -q "\`${OLD_VERSION}\`" "$file"; then
        pass "$file contains \`OLD_VERSION\`"
      else
        fail "$file does not contain \`OLD_VERSION\`"
      fi
      ;;
    .omp/skills/template-guide/SKILL.md)
      if grep -q "(${OLD_VERSION})" "$file"; then
        pass "$file contains (OLD_VERSION) in examples"
      else
        fail "$file does not contain (OLD_VERSION) in examples"
      fi
      ;;
    .omp/skills/template-guide/scripts/audit.sh)
      if grep -q "TEMPLATE_VERSION=${OLD_VERSION}" "$file"; then
        pass "$file contains TEMPLATE_VERSION=$OLD_VERSION"
      else
        fail "$file does not contain TEMPLATE_VERSION=$OLD_VERSION"
      fi
      ;;
    CHANGELOG.md)
      if grep -q "## \[${OLD_VERSION}\]" "$file"; then
        pass "$file contains [OLD_VERSION] section"
      else
        fail "$file does not contain [OLD_VERSION] section"
      fi
      ;;
  esac
done

if [[ $ERRORS -gt 0 ]]; then
  fatal "Pre-flight failed: $ERRORS file(s) missing OLD_VERSION"
fi

echo ""

# ── Update Files ─────────────────────────────────────────────────────────────

echo "=== Updating version manifest: $OLD_VERSION → $NEW_VERSION ==="

for file in "${MANIFEST[@]}"; do
  echo "Updating $file..."

  case "$file" in
    .template-version)
      echo "$NEW_VERSION" > "$file"
      ;;

    README.md)
      sed -i "s/template-v${OLD_VERSION}/template-v${NEW_VERSION}/g" "$file"
      ;;

    AGENTS.md)
      sed -i "s/version \*\*${OLD_VERSION}\*\*/version \*\*${NEW_VERSION}\*\*/" "$file"
      ;;

    SETUP_GUIDE.md)
      sed -i "s/\`${OLD_VERSION}\`/\`${NEW_VERSION}\`/g" "$file"
      ;;

    .omp/skills/template-guide/SKILL.md)
      sed -i "s/(${OLD_VERSION})/(${NEW_VERSION})/g" "$file"
      ;;

    .omp/skills/template-guide/scripts/audit.sh)
      sed -i "s/TEMPLATE_VERSION=${OLD_VERSION}/TEMPLATE_VERSION=${NEW_VERSION}/" "$file"
      ;;

    CHANGELOG.md)
      python3 .omp/skills/cut-release/scripts/update_changelog.py "$NEW_VERSION" "$DATE_NOW" "$OLD_VERSION"
      ;;
  esac

  pass "Updated $file"
done

echo ""

# ── Post-flight: Verify NEW_VERSION exists in all manifest files ─────────────

echo "=== Post-flight: Verifying NEW_VERSION ($NEW_VERSION) in all manifest files ==="
ERRORS=0

for file in "${MANIFEST[@]}"; do
  case "$file" in
    .template-version)
      if grep -q "^${NEW_VERSION}$" "$file"; then
        pass "$file contains NEW_VERSION"
      else
        fail "$file does not contain NEW_VERSION as exact version"
      fi
      ;;
    README.md)
      if grep -q "template-v${NEW_VERSION}" "$file"; then
        pass "$file references NEW_VERSION in badge"
      else
        fail "$file does not reference NEW_VERSION in badge"
      fi
      ;;
    AGENTS.md)
      if grep -q "version \*\*${NEW_VERSION}\*\*" "$file"; then
        pass "$file contains 'version **NEW_VERSION**'"
      else
        fail "$file does not contain 'version **NEW_VERSION**'"
      fi
      ;;
    SETUP_GUIDE.md)
      if grep -q "\`${NEW_VERSION}\`" "$file"; then
        pass "$file contains \`NEW_VERSION\`"
      else
        fail "$file does not contain \`NEW_VERSION\`"
      fi
      ;;
    .omp/skills/template-guide/SKILL.md)
      if grep -q "(${NEW_VERSION})" "$file"; then
        pass "$file contains (NEW_VERSION) in examples"
      else
        fail "$file does not contain (NEW_VERSION) in examples"
      fi
      ;;
    .omp/skills/template-guide/scripts/audit.sh)
      if grep -q "TEMPLATE_VERSION=${NEW_VERSION}" "$file"; then
        pass "$file contains TEMPLATE_VERSION=$NEW_VERSION"
      else
        fail "$file does not contain TEMPLATE_VERSION=$NEW_VERSION"
      fi
      ;;
    CHANGELOG.md)
      if grep -q "## \[${NEW_VERSION}\]" "$file"; then
        pass "$file contains [NEW_VERSION] section"
      else
        fail "$file does not contain [NEW_VERSION] section"
      fi
      ;;
  esac
done

# Also check OLD_VERSION is gone (except CHANGELOG historical)
echo ""
echo "=== Checking OLD_VERSION is gone from version-bearing files ==="
for file in README.md AGENTS.md SETUP_GUIDE.md .omp/skills/template-guide/SKILL.md; do
  if grep -q "v${OLD_VERSION}" "$file" 2>/dev/null; then
    fail "$file still references OLD_VERSION"
  else
    pass "$file no longer references OLD_VERSION"
  fi
done

if [[ $ERRORS -gt 0 ]]; then
  fatal "Post-flight failed: $ERRORS file(s) not updated correctly"
fi

echo ""

# ── Run audit.sh ─────────────────────────────────────────────────────────────

echo "=== Running audit.sh ==="
if bash .omp/skills/template-guide/scripts/audit.sh; then
  echo ""
  echo "=== Audit passed ==="
else
  fatal "Audit failed. Check output above."
fi

echo ""

# ── Summary ───────────────────────────────────────────────────────────────────

echo "=== Summary of Changes ==="
git diff --stat

echo ""
echo "=== Release version bump complete: $OLD_VERSION → $NEW_VERSION ==="
echo "Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Commit: git add -A && git commit -m 'chore: cut v$NEW_VERSION'"
echo "  3. Push: git push -u origin HEAD"
echo "  4. Create PR, merge, tag, and create GitHub release"