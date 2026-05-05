#!/usr/bin/env bash
# audit.sh — Compliance audit for ai-project-template repos
# Run from any directory in the repo:
#   bash .omp/skills/template-guide/scripts/audit.sh

# TEMPLATE_VERSION: This file is part of the ai-project-template version manifest.
# cut-release.sh updates this line on each release.
TEMPLATE_VERSION=0.6.0

set -euo pipefail

# scripts/ → template-guide → skills → .omp → repo-root = 4 levels up
SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
cd "$SCRIPT_DIR"
cd ../../../..

ERRORS=0

pass() { echo "[PASS] $*"; }
fail() { echo "[FAIL] $*" >&2; ERRORS=$((ERRORS + 1)); }

# ── 1. Scaffolding files leftover ──────────────────────────────────────────
echo "Checking for leftover scaffolding files..."
SCAFFOLDING_FILES="SETUP_GUIDE.md ADOPTING.md UPGRADING.md"
if [ -f "AGENTS.md" ]; then
    # Check if AGENTS.md has been customized (no generic placeholders)
    if ! grep -q '<!-- project name -->' AGENTS.md && ! grep -q '<!-- one-line description -->' AGENTS.md; then
        for f in $SCAFFOLDING_FILES; do
            if [ -f "$f" ]; then
                fail "$f exists but AGENTS.md has been filled in — setup was completed but scaffolding was not cleaned up"
                echo "  → Run: rm -f $SCAFFOLDING_FILES"
            fi
        done
    else
        if [ -f "SETUP_GUIDE.md" ]; then
            pass "SETUP_GUIDE.md exists (setup in progress)"
        fi
    fi
else
    pass "No leftover scaffolding files detected"
fi

# ── 2. Placeholder detection in all .md files ──────────────────────────────
echo "Checking all markdown files for placeholders..."
PLACEHOLDER_ERRORS=0
while IFS= read -r md; do
    # Skip draft/notes files that are intentionally incomplete
    case "$md" in
        */drafts/*|*/.notes/*) continue ;;
    esac
    # Match HTML comment placeholders with common patterns
    PLACEHOLDERS=$(grep -n '<!--\s*\(e\.g\.\|TODO\|FIXME\|replace me\|fill in\|... -->\|<!-- -->\|project name\|one-line description\|e\.g\.\|example\|<!-- .* --><!-- .* -->' "$md" 2>/dev/null || true)
    if [ -n "$PLACEHOLDERS" ]; then
        fail "$md has HTML comment placeholders:"
        echo "$PLACEHOLDERS" | while IFS= read -r line; do
            echo "  $line"
        done
        PLACEHOLDER_ERRORS=$((PLACEHOLDER_ERRORS + 1))
    fi
done < <(find . -name '*.md' -type f ! -path '*/node_modules/*' 2>/dev/null || true)
if [ "$PLACEHOLDER_ERRORS" -eq 0 ]; then
    pass "All markdown files are clean (no placeholders)"
fi

# ── 3. Required files ───────────────────────────────────────────────────────
echo "Checking required files..."
for f in CHANGELOG.md CONTRIBUTING.md AGENTS.md README.md; do
    if [ -f "$f" ]; then
        pass "$f exists"
    else
        fail "$f is missing"
    fi
done

# ── 4. CI workflow files ───────────────────────────────────────────────────
echo "Checking CI workflows..."
for wf in ci.yml commit-lint.yml changelog-check.yml blob-size-policy.yml branch-lint.yml; do
    WF_PATH=".github/workflows/$wf"
    if [ -f "$WF_PATH" ]; then
        if [ -s "$WF_PATH" ]; then
            pass "$wf exists and is not empty"
        else
            fail "$wf is empty"
        fi
    else
        fail "$wf is missing"
    fi
done

# ── 5. .template-version ───────────────────────────────────────────────────
echo "Checking .template-version..."
if [ -f ".template-version" ]; then
    VERSION=$(cat .template-version | tr -d '[:space:]')
    # Validate semver format: X.Y.Z (the real invariant)
    if echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
        pass ".template-version is valid semver ($VERSION)"
    else
        fail ".template-version is not valid semver: $VERSION"
    fi
else
    fail ".template-version is missing"
fi

# ── 6. Internal markdown links ─────────────────────────────────────────────
echo "Checking internal markdown links..."
LINK_ERRORS=0
while IFS= read -r md; do
    # Match [text](path) where path starts with ./ or / (local) but NOT http:// or https://
    while IFS= read -r link; do
        # Extract the path part inside parentheses
        PATH_PART=$(echo "$link" | sed 's/.*\](\([^)]*\)).*/\1/')
        # Skip external links
        case "$PATH_PART" in
            http://*|https://*) continue ;;
        esac
        # Remove leading ./
        TARGET=${PATH_PART#./}
        # Strip URL anchors (#...) before checking file existence
        BASE=${TARGET%%#*}
        # Only check existence if BASE is non-empty (skip pure anchors like "#section")
        if [[ -n "$BASE" ]] && [ ! -e "$BASE" ]; then
            fail "$md links to missing $BASE"
            LINK_ERRORS=$((LINK_ERRORS + 1))
        fi
    done < <(grep -oE '\[([^]]+)\]\([^)]+\)' "$md" 2>/dev/null || true)
done < <(find . -name '*.md' -type f | sort)
if [ "$LINK_ERRORS" -eq 0 ]; then
    pass "all internal markdown links resolve"
fi

# ── 7. Version manifest consistency ───────────────────────────────────────
echo "Checking version manifest consistency..."
VERSION=$(cat .template-version 2>/dev/null | tr -d '[:space:]') || VERSION=""

check_manifest() {
    local file=$1 pattern=$2
    if [ -f "$file" ]; then
        if grep -q "$pattern" "$file" 2>/dev/null; then
            pass "$file references version $VERSION"
        else
            fail "$file does not reference version $VERSION (expected pattern: $pattern)"
        fi
    else
        fail "$file does not exist"
    fi
}

# Check each manifest file contains the current version
check_manifest "README.md" "template-v${VERSION}"
check_manifest "AGENTS.md" "version \*\*${VERSION}\*\*"
check_manifest "SETUP_GUIDE.md" "${VERSION}"
check_manifest ".omp/skills/template-guide/SKILL.md" "template-version: ${VERSION}"

# ── 8. Pre-commit config ────────────────────────────────────────────────────
echo "Checking pre-commit config..."
if [ -f ".pre-commit-config.yaml" ]; then
    pass ".pre-commit-config.yaml exists"
else
    fail ".pre-commit-config.yaml is missing (run: pip install pre-commit && pre-commit install)"
fi

# ── Summary ─────────────────────────────────────────────────────────────────
echo ""
if [ "$ERRORS" -eq 0 ]; then
    echo "=== All checks passed ==="
    exit 0
else
    echo "=== $ERRORS check(s) failed ==="
    exit 1
fi
