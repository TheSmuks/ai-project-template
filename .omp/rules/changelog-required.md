---
name: changelog-required
description: Reminds agents to update CHANGELOG.md for user-facing changes
type: scope
version: 1.0.0
---

# Changelog Required Rule

## Purpose

Ensures that any user-facing change to the codebase is accompanied by a `CHANGELOG.md` entry under the `[Unreleased]` section. This keeps the changelog accurate and reduces the friction of release notes.

## When This Rule Applies

The rule activates when the agent edits or writes to files that represent user-facing surfaces:

```
tool:write(**/*.{ts,js,py,go,rs,md,json,yaml,yml})
tool:edit(**/*.{ts,js,py,go,rs,md,json,yaml,yml})
exclude:
  - "**/test/**"
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/CHANGELOG.md"
  - "**/scripts/**"
  - "**/tools/**"
  - ".github/workflows/**"
  - "docs/**"
```


When this rule activates, the agent should:

1. **Check if the change is user-facing** — does it modify behavior, add features, fix bugs that users care about?
2. **If yes**, update `CHANGELOG.md` under `[Unreleased]`:
   ```markdown
   ## [Unreleased]
   
   ### Added
   - New feature description here
   
   ### Changed
   - Behavioral change description here
   
   ### Fixed
   - Bug fix description here
   
   ### Deprecated
   - Deprecation notice here
   
   ### Removed
   - Removal description here
   ```

3. **Use the correct category** per [Keep a Changelog](https://keepachangelog.com/):
   - `Added` — new features
   - `Changed` — changes to existing functionality
   - `Deprecated` — soon-to-be removed features
   - `Removed` — removed features
   - `Fixed` — bug fixes
   - `Security` — vulnerability fixes

4. **Write descriptive entries** — avoid generic "updated X" or "changed Y"

## Why This Rule Exists

- **Release friction** — changelogs updated incrementally are less painful than hunting for changes at release time
- **Visibility** — users need to know what changed, not just that something changed
- **Compliance** — many projects require changelog entries for CI to pass

## Adapting This Rule

Adopting projects may customize:

### Change the changelog file path
```yaml
scope:
  tool:write(**/*.{ts,js,py,go,rs,md,json,yaml,yml})
  tool:edit(**/*.{ts,js,py,go,rs,md,json,yaml,yml})
  exclude:
    - "**/test/**"
    - "**/CHANGELOG.md"
    - "docs/changelog/**"
```

### Add additional exclusion patterns
```yaml
exclude:
  - "**/test/**"
  - "**/__fixtures__/**"
  - "**/*.generated.*"
```

### Use a different changelog format
If your project uses a different format, update the reminder text accordingly.

## Implementation Notes

This is a **scope-based rule** — it activates based on file patterns and is always in context when those patterns match. Unlike TTSR rules, scope-based rules have a small upfront context cost but provide consistent coverage.

For projects with many files, consider whether a TTSR rule would suffice (triggering only when "CHANGELOG" appears in context) to reduce context load.
