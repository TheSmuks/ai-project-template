---
name: review
description: Review staged git changes for issues before committing
---

Review the currently staged git changes (`git diff --cached`). Focus on:

1. **Correctness**: Logic errors, off-by-one, missing null/edge case handling
2. **Security**: Hardcoded secrets, SQL injection, unsafe deserialization, path traversal
3. **Performance**: N+1 queries, unnecessary allocations, missing batch processing
4. **Style**: Naming conventions, dead code, inconsistent patterns

Output a concise summary with:
- List of issues found (or confirmation that changes look clean)
- Severity level for each issue (critical / warning / nit)
- Suggested fix for each issue

Do NOT suggest changes that are out of scope for the current diff.
