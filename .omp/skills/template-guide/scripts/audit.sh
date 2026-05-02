#!/usr/bin/env bash
# audit.sh — Compliance audit for ai-project-template repos
# Run from any directory in the repo:
#   bash .omp/skills/template-guide/scripts/audit.sh

set -euo pipefail

# scripts/ → template-guide → skills → .omp → repo-root = 4 levels up
cd "$(dirname "${BASH_SOURCE[0]}")"
cd ../../../..

ERRORS=0

pass() { echo "PASS: $*"; }
fail() { echo "FAIL: $*"; ERRORS=$((ERRORS + 1)); }

# ── 1. AGENTS.md: no HTML comment placeholders ──────────────────────────────
echo "Checking AGENTS.md for placeholders..."
if [ -f "AGENTS.md" ]; then
    PLACEHOLDERS=$(grep -n '<!-- -->' AGENTS.md 2>/dev/null || true)
    if [ -n "$PLACEHOLDERS" ]; then
        fail "AGENTS.md has placeholders remaining:"
        echo "$PLACEHOLDERS" | while IFS= read -r line; do
            echo "  $line"
        done
    else
        pass "AGENTS.md has no placeholders"
    fi
else
    fail "AGENTS.md is missing"
fi

# ── 2. Required files ───────────────────────────────────────────────────────
echo "Checking required files..."
for f in CHANGELOG.md CONTRIBUTING.md AGENTS.md README.md; do
    if [ -f "$f" ]; then
        pass "$f exists"
    else
        fail "$f is missing"
    fi
done

# ── 3. CI workflow files ────────────────────────────────────────────────────
echo "Checking CI workflows..."
for wf in ci.yml commit-lint.yml changelog-check.yml blob-size-policy.yml; do
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

# ── 4. .template-version ────────────────────────────────────────────────────
echo "Checking .template-version..."
if [ -f ".template-version" ]; then
    VERSION=$(cat .template-version | tr -d '[:space:]')
    KNOWN="0.1.0 0.2.0 0.3.0 0.4.0 0.5.0"
    if echo "$KNOWN" | grep -qw "$VERSION"; then
        pass ".template-version matches known release ($VERSION)"
    else
        fail ".template-version has unknown version: $VERSION"
    fi
else
    fail ".template-version is missing"
fi

# ── 5. Internal markdown links ──────────────────────────────────────────────
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
        if [ ! -e "$BASE" ]; then
            fail "$md links to missing $BASE"
            LINK_ERRORS=$((LINK_ERRORS + 1))
        fi
    done < <(grep -oE '\[([^]]+)\]\(\.?/[^)]+\)' "$md" 2>/dev/null || true)
done < <(find . -name '*.md' -type f | sort)
if [ "$LINK_ERRORS" -eq 0 ]; then
    pass "all internal markdown links resolve"
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
