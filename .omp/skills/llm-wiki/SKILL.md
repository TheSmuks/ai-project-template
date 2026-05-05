---
name: llm-wiki
description: Maintain a personal team knowledge base using the LLM Wiki pattern — incremental ingest, query, and lint operations on a layered wiki architecture
category: knowledge-management
tags: [wiki, knowledge-base, documentation, research, note-taking, obsidian]
version: 1.0.0
---

# LLM Wiki

A pattern for building and maintaining a structured, interlinked collection of markdown files — a personal or team knowledge base — using LLM agents. The wiki is maintained incrementally alongside code work.

## When to Use

Invoke this skill when you want to:
- Capture research, decisions, or references from web searches or documents into a persistent knowledge base
- Query accumulated knowledge to answer questions that require synthesizing multiple sources
- Maintain a log of what the wiki has grown to contain
- Onboard a new agent or human to a topic by pointing them at the wiki

The wiki is **opt-in**. Projects that don't need it are unaffected. Projects that do can build it up over time.

## Setup

When activating this skill on a fresh project, create the wiki directory structure and seed files:

```bash
mkdir -p wiki raw
touch wiki/index.md wiki/log.md
```

### `wiki/index.md` Template

```markdown
# Wiki Index

> Content catalog for the LLM Wiki. Maintained by agents after each ingest operation.

## Topics

<!-- Add entries as you create pages:

- [[topic-name]] — Brief description

-->

## Recent Additions

<!-- Chronological list of new pages:

- [[YYYY-MM-DD]] [[page-name]] — Why it was added

-->
```

### `wiki/log.md` Template

```markdown
# Wiki Log

> Append-only chronological record of wiki operations. Never edit past entries.

## Usage

Each entry follows this format:

```
## YYYY-MM-DD

### ingest
- **Sources:** <!-- list of sources added -->
- **Pages created:** <!-- list -->
- **Pages updated:** <!-- list -->
- **Summary:** <!-- one-liner on why -->

### query
- **Question:** <!-- what was asked -->
- **Answered by:** <!-- pages consulted -->
- **Summary:** <!-- answer or "no answer found" -->

### lint
- **Issues found:** <!-- count -->
- **Issues fixed:** <!-- count -->
- **Summary:** <!-- overall health -->
```

---

## Architecture

The wiki operates in three layers:

```
┌─────────────────────────────────────────────────────────────┐
│  Raw Sources          (immutable, timestamped inputs)        │
│  raw/                                                       │
│  PDFs, web captures, transcript files, etc.                │
└─────────────────────────────────────────────────────────────┘
                          │ Ingest
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  Wiki                   (LLM-maintained markdown pages)      │
│  wiki/                                                      │
│  Topic pages, concept notes, decision records, etc.        │
│  Linked via [[wiki-links]]                                  │
└─────────────────────────────────────────────────────────────┘
                          │ Synthesize
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  Schema                 (instructions for AGENTS.md)         │
│  Key facts, conventions, decisions that agents must follow   │
└─────────────────────────────────────────────────────────────┘
```

### Raw Sources (`raw/`)

Immutable source material. Never edit after creation — this preserves provenance.

**Naming convention:**
```
YYYY-MM-DD-<slug>.<ext>
```
Example: `2024-01-15-attention-mechanism-paper.pdf`

### Wiki Pages (`wiki/`)

Markdown files maintained by agents. Organized by topic, linked via `[[double-bracket]]` links (standard in Obsidian, supported by most markdown link tools).

**Naming convention:**
```
<topic>-<subtopic>.md
```
Example: `attention-mechanism.md`, `transformers-vanishing-gradients.md`

**Frontmatter (required):**
```yaml
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [tag1, tag2]
---

# Topic Title

...
```

### Schema Layer

Facts, conventions, and decisions extracted from the wiki and incorporated into `AGENTS.md` or project documentation. This is the loop that closes: wiki → actionable agent knowledge.

---

## Operations

### Ingest

Add new sources and update the wiki with their content.

**When to ingest:**
- After a research session (web search, paper reading, documentation review)
- When adding a new topic page
- When updating an existing page with new information

**Steps:**

1. **Create raw source entry** (if source is new):
   ```bash
   cp <source-file> raw/$(date +%Y-%m-%d)-<slug>.<ext>
   ```

2. **Read and extract key information** from the source.

3. **Create or update wiki page** at `wiki/<topic>.md`:
   - Use the frontmatter template
   - Link to related pages with `[[wiki-links]]`
   - Include a "Sources" section with references

4. **Update `wiki/index.md`**:
   - Add the new topic entry
   - Add a "Recent Additions" entry with date

5. **Append to `wiki/log.md`**:
   ```markdown
   ### ingest
   - **Sources:** <!-- -->
   - **Pages created:** <!-- -->
   - **Pages updated:** <!-- -->
   - **Summary:** <!-- -->
   ```

### Query

Answer a question by consulting the wiki.

**When to query:**
- Before starting work on a topic you haven't touched recently
- When you need to recall a decision made in a previous session
- When onboarding and you need to understand the project context

**Steps:**

1. **Read `wiki/index.md`** to find relevant topic pages.

2. **Read the relevant wiki pages** for the topic.

3. **Synthesize an answer** from the wiki content.

4. **Append to `wiki/log.md`**:
   ```markdown
   ### query
   - **Question:** <!-- -->
   - **Answered by:** <!-- pages consulted -->
   - **Summary:** <!-- answer or "no answer found" -->
   ```

### Lint

Health-check the wiki for issues.

**When to lint:**
- Before a release or handoff
- When the wiki starts to feel disorganized
- As a periodic maintenance step

**Steps:**

1. **Check for orphaned pages** — files that nothing links to:
   ```bash
   # Find markdown files with no [[links]] pointing to them
   find wiki -name '*.md' -exec grep -L "^\\[\\[" {} \;
   ```

2. **Check for broken links** — `[[wiki-links]]` that point to non-existent pages:
   ```bash
   grep -roh '\[\[[^]]\+\]\]' wiki/ | sed 's/\[\[\(.*\)\]\]/\1/' | while read page; do
     [ -f "wiki/$page.md" ] || echo "MISSING: $page"
   done
   ```

3. **Check frontmatter** — all pages should have `created`, `updated`, and `tags`.

4. **Fix issues** found during the check.

5. **Append to `wiki/log.md`**:
   ```markdown
   ### lint
   - **Issues found:** <!-- count -->
   - **Issues fixed:** <!-- count -->
   - **Summary:** <!-- overall health -->
   ```

---

## Page Templates

### Concept Page

```markdown
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [concept, area]
---

# Concept Name

One-line definition or summary.

## Background

Why this concept matters.

## Key Points

- Point 1
- Point 2

## Related

- [[related-page-1]]
- [[related-page-2]]

## Sources


```

### Decision Record

```markdown
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [decision, area]
---

# Decision: Short Title

**Status:** Proposed | Accepted | Deprecated
**Date:** YYYY-MM-DD

## Context

What situation forces this decision?

## Decision

What was decided?

## Consequences

What changes because of this decision?

## Related

- [[related-page]]
```

---

## Optional Tooling

These integrations are optional — the wiki works as plain markdown files.

### Obsidian

The wiki format is fully compatible with [Obsidian](https://obsidian.md/). Just open the `wiki/` folder as a vault.

**Recommended plugins:**
- `obsidian-markdown-links` — render `[[wiki-links]]` as navigable links
- `obsidian-dataview` — query pages by tags, created date, etc.

### qmd (Quick Markdown Search)

A lightweight search engine for markdown files. Index your wiki:

```bash
# Install qmd (if available)
pip install qmd

# Index the wiki
qmd index wiki/

# Query
qmd search "attention mechanism"
```

### Marp Slides

Generate presentations from wiki content:

```bash
# Install Marp CLI
npm install -g @marp-team/marp-cli

# Convert a page to slides
marp wiki/attention-mechanism.md --output slides/
```

---

## Integration with AGENTS.md

When the wiki is established, add conventions to `AGENTS.md`:

```markdown
## Wiki

This project maintains a knowledge base at `wiki/`. Before starting work on a topic, query the wiki:

```bash
# Check for relevant pages
grep -r "topic" wiki/ --include="*.md"
```

After research or significant decisions, ingest into the wiki per the `llm-wiki` skill.
```

---

## References

- [Karpathy's LLM Wiki (original gist)](https://github.com/karpathy/llm-wiki) — Source of this pattern
- [Obsidian](https://obsidian.md/) — Recommended local interface
- [Marp](https://marp.app/) — Markdown presentation engine
