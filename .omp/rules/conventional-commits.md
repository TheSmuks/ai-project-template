---
name: conventional-commits
description: Enforces conventional commit format when generating commit messages
type: ttsr
version: 1.0.0
---

# Conventional Commits Rule

## Purpose

Ensures that commit messages follow the [Conventional Commits](https://www.conventionalcommits.org/) specification. This enables:
- Automated changelog generation
- Semantic versioning
- Clear commit history
- Consistent tooling integration

## Trigger

This rule activates via TTSR (zero upfront context cost) when the agent's output matches patterns that indicate a non-conventional commit message.

## Trigger Pattern

Regex: `^(?!feat|fix|docs|style|refactor|perf|test|build|ci|chore)(\b[A-Z][a-z]+\b|\b[A-Z]{2,}\b)`

### What This Catches

| Pattern | Example | Why It's Wrong |
|---------|---------|----------------|
| `^Update` | "Update README.md" | Missing `docs:` prefix |
| `^Added` | "Added new feature" | Should be `feat:` |
| `^Fixed` | "Fixed bug" | Should be `fix:` |
| `^Changed` | "Changed API" | Should be `Changed:` as category, not verb |
| `^[A-Z]{2,}` | "README updates" | All-caps abbreviation starts wrong |

### What This Does NOT Catch

- Already-correct commits (`feat: add user auth`, `fix: resolve null pointer`)
- Multi-word descriptions after the type (`feat: add OAuth2 support`)
- Branch names or PR titles

## Scope

```
tool:bash(git commit*)
```

This ensures the rule only activates when the agent is committing, not during general chat.

## The Format

Conventional commits follow this structure:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Valid Types

| Type | Description |
|------|-------------|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation only changes |
| `style` | Changes that don't affect code meaning (formatting, semicolons, etc.) |
| `refactor` | A code change that neither fixes a bug nor adds a feature |
| `perf` | A code change that improves performance |
| `test` | Adding missing tests or correcting existing tests |
| `build` | Changes that affect the build system or external dependencies |
| `ci` | Changes to CI configuration files and scripts |
| `chore` | Other changes that don't modify src or test files |

### Optional Scope

The scope provides context about what was changed:

```
feat(auth): add OAuth2 login
fix(api): resolve race condition in token refresh
docs(readme): update installation instructions
```

### Description Rules

- Use imperative mood: "add feature" not "added feature"
- No period at the end
- Start with lowercase
- Be concise (72 characters max for first line)

## Example Fixes

### ❌ Non-conventional (triggers warning)
```
Update user authentication
```
**Fix:**
```
feat(auth): add user authentication
```

### ❌ Non-conventional
```
Fixed the null pointer exception in the API handler
```
**Fix:**
```
fix(api): resolve null pointer in request handler
```

### ✅ Conventional (no trigger)
```
feat(billing): add Stripe payment integration

Implements one-time and subscription payment flows.
Stores payment intents in the database for reconciliation.
```

## Adapting This Rule

### Custom Types

If your project uses additional types beyond the standard set:

```yaml
trigger: "^(?!feat|fix|docs|style|refactor|perf|test|build|ci|chore|deps|security)(\\b[A-Z][a-z]+\\b|\\b[A-Z]{2,}\\b)"
```

### Relaxed Validation

For teams transitioning from non-conventional commits, you may want to warn rather than error:

```yaml
enforcement: warning  # instead of error
```

### Scope Enforcement

To require scope on certain types:

```yaml
# Modify the reminder text to indicate:
"Types like feat, fix, and refactor should include a scope indicating what was changed."
```

## Implementation Notes

This is a **TTSR rule** — it only activates when its pattern appears in the agent's output during a `git commit` command. This provides:
- Zero upfront context cost
- Targeted enforcement at commit time
- No interference with general workflow

### Limitations

This TTSR rule has important limitations due to the nature of stream-based detection:

1. **No colon enforcement** — The rule does not check for the required `:` separator after the type. A message like `feat some description` (missing colon) will NOT trigger this rule.
2. **Single-line check** — The rule only examines the first token. Multi-line messages may not be fully validated.
3. **Real enforcement via CI** — For complete validation, rely on the `commit-lint.yml` CI workflow, which performs proper conventional commit parsing including the `:` separator.

**Note:** The TTSR rule provides lightweight guidance during development, but CI enforcement (commit-lint.yml) is authoritative.


The rule uses a negative lookahead pattern to only trigger when the commit does NOT start with a valid type.
