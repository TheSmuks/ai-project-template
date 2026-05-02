# OMP Extensions Guide

A practical decision guide for the six Oh My Pi extension types: **agents**, **commands**, **skills**, **rules**, **hooks**, and **tools**. Each type solves a different problem; choosing the wrong one leads to friction.

For AGENTS.md, ARCHITECTURE.md, and SKILL.md guidance, see [agent-files-guide.md](./docs/agent-files-guide.md).

---

## Quick Decision Matrix

| You want to... | Use | Why |
|----------------|-----|-----|
| Give the agent a reusable multi-step workflow | **Skill** | Self-contained package, on-demand loading, can include scripts |
| Run a quick prompt template from chat | **Command** | Lightweight, argument substitution, no code needed |
| Prevent the agent from doing something wrong | **Rule** | Zero-cost injection when pattern matches |
| Always enforce a convention | **Rule (scope-based)** | Loaded when relevant scope matches |
| Intercept or modify a tool call before it runs | **Hook (pre)** | TypeScript, can block/modify/prompt before execution |
| React after something happens | **Hook (post)** | TypeScript, read-only reaction to completed events |
| Add a new callable tool the model can invoke | **Tool** | TypeScript, appears in model's tool list, structured I/O |
| Define a specialist sub-agent | **Agent** | Model + tools + system prompt, spawned via task tool |

---

## Extension Type Catalog

### 1. Agents

**What it is:** A named sub-agent with its own model configuration, toolset, and system prompt. Defined via YAML frontmatter + markdown in `.omp/agents/`.

**When to use:**
- You want a specialist that handles one concern (code review, ADR writing, changelog updates)
- The agent needs different behavior than the main agent (different model, different tools)
- You frequently delegate to the same type of task

**When NOT to use:**
- The task is one-off and doesn't need a reusable specialist
- You need to modify behavior at call time, not definition time
- The agent would be a thin wrapper around a simpler mechanism

**Format:** `.omp/agents/<name>.md`

```yaml
---
name: code-reviewer
description: Reviews pull requests for correctness, security, and style
model: gpt-4o
temperature: 0.3
tools: [tool:read, tool:search, tool:lsp, tool:bash]
version: 1.0.0
---

# Code Reviewer Agent

## Role

You are a code reviewer specializing in...

[rest of agent definition]
```

**Examples in this repo:**
- [`.omp/agents/code-reviewer.md`](.omp/agents/code-reviewer.md)
- [`.omp/agents/adr-writer.md`](.omp/agents/adr-writer.md)
- [`.omp/agents/changelog-updater.md`](.omp/agents/changelog-updater.md)

**Context cost:** Loaded when spawned via task tool; not loaded in main session.

---

### 2. Commands

**What it is:** A reusable prompt template stored in `.omp/commands/`. Invoked via `/<name>` in chat, with optional argument substitution.

**When to use:**
- You want a quick prompt you can trigger from chat
- The workflow is one or two steps
- No custom logic or tool calls needed

**When NOT to use:**
- The workflow requires multi-step logic or conditional branches
- You need to call tools programmatically
- The prompt is complex enough to need its own file

**Format:** `.omp/commands/<name>.md`

```markdown
---
name: review
description: Request a code review from the specialist agent
arguments:
  - name: target
    description: File or PR to review
    required: true
---

# Code Review Request

Review the following target:

{{target}}

Focus on:
- Correctness
- Security
- Style adherence
```

**Examples in this repo:**
- [`.omp/commands/review.md`](.omp/commands/review.md)

**Context cost:** Loaded on invocation; arguments substituted before loading.

---

### 3. Skills

**What it is:** A packaged capability with instructions, optional scripts, and references. Loaded on demand via the skill system.

**When to use:**
- The capability has multiple steps or phases
- The workflow needs conditional logic
- You want to include helper scripts
- The skill represents a complete workflow pattern

**When NOT to use:**
- The capability is a single prompt (use a command instead)
- You need to intercept tool calls (use a hook instead)
- The capability is purely reactive (use a hook instead)

**Format:** `.omp/skills/<name>/SKILL.md` with optional `scripts/` and `references/` subdirectories.

```
skill-name/
  SKILL.md              # Required: skill definition
  scripts/              # Optional: helper scripts
    helper.sh
  references/           # Optional: docs and templates
    template.md
```

**Examples in this repo:**
- [`.omp/skills/cut-release/`](.omp/skills/cut-release/)
- [`.omp/skills/merge-to-main/`](.omp/skills/merge-to-main/)
- [`.omp/skills/template-guide/`](.omp/skills/template-guide/)
- [`.omp/skills/setup/`](.omp/skills/setup/)

**Context cost:** Loaded on skill invocation; progressive disclosure keeps cost proportional to usage.

---

### 4. Rules

**What it is:** Convention enforcement via two mechanisms: **TTSR** (stream-triggered, zero upfront cost) and **scope-based** (activated by file/tool patterns, always in context when relevant).

**When to use:**
- You want to prevent or warn about specific patterns
- The convention applies to many situations but isn't always relevant
- You want zero overhead until the pattern matches

**When NOT to use:**
- The rule needs to run logic that can't be expressed as a regex match
- The rule needs to inspect the full context (file contents, not just path)
- The behavior requires modifying the operation, not just warning

**Format:** `.omp/rules/<name>.md`

```yaml
---
name: no-placeholders
description: Prevents HTML comment placeholders in template files
type: ttsr  # or "scope"
version: 1.0.0
---

# Rule Name

## Purpose

[One paragraph on what this prevents]

## Trigger

[TTSR rules: the regex pattern]
[Scope rules: the scope pattern]

## What To Do Instead

[Practical guidance]
```

**TTSR vs Scope Rules**

| Aspect | TTSR | Scope-based |
|--------|------|------------|
| Context cost | Zero until match | Small, always loaded |
| Activation | Stream pattern match | File/tool scope match |
| Best for | Prevent specific text patterns | Always-on conventions |
| Examples | No placeholders, commit format | Changelog reminders |

**Examples in this repo:**
- [`.omp/rules/no-placeholders.md`](.omp/rules/no-placeholders.md) (TTSR)
- [`.omp/rules/changelog-required.md`](.omp/rules/changelog-required.md) (scope)
- [`.omp/rules/conventional-commits.md`](.omp/rules/conventional-commits.md) (TTSR)

**Context cost:** TTSR rules are zero-cost until matched; scope-based rules have small upfront cost proportional to scope size.

---

### 5. Hooks

**What it is:** TypeScript modules that subscribe to OMP lifecycle events. **Pre-hooks** run before an action completes; **post-hooks** run after.

**When to use:**
- You need to intercept and potentially block a tool call
- You need to prompt the user before an operation
- You need to react to completed operations (logging, notifications)
- The logic requires TypeScript (not expressible as a pattern)

**When NOT to use:**
- The behavior is purely advisory (use a rule instead)
- The logic is a simple pattern match (use a TTSR rule instead)
- You don't need to modify behavior or prompt

**Format:** `.omp/hooks/pre/<name>.ts` or `.omp/hooks/post/<name>.ts`

```typescript
import { OmpPreHook, ToolCallEvent, BashToolCall } from '@oh-my-pi/sdk';
import { OmpPostHook, WriteEditToolCall } from '@oh-my-pi/sdk';

// Pre-hook: runs before action completes
// Return true to allow, false to block the operation
export const myPreHook: OmpPreHook = async (event: ToolCallEvent): Promise<boolean> => {
  if (event.tool === 'tool:bash') {
    const bashCall = event as BashToolCall;
    // Example: Block dangerous commands
    if (bashCall.arguments.command.includes('rm -rf /')) {
      console.warn('[my-hook] BLOCKED: Dangerous command detected');
      return false; // Block the operation
    }
  }
  return true; // Allow by default
};

// Post-hook: runs after action completes
export const myPostHook: OmpPostHook = async (event: ToolCallEvent): Promise<void> => {
  if (event.tool === 'tool:write' || event.tool === 'tool:edit') {
    const writeCall = event as WriteEditToolCall;
    console.log('[my-hook] File modified: ', writeCall.arguments.path);
  }
};
```

**Pre-hook Use Cases:**
- Protect branches from direct commits (prompt user)
- Validate file paths before write operations
- Require confirmation for destructive operations

**Post-hook Use Cases:**
- Log template-critical file changes
- Notify external systems (Slack, etc.)
- Trigger downstream processes (CI, deployments)

**Examples in this repo:**
- [`.omp/hooks/pre/protect-main.ts`](.omp/hooks/pre/protect-main.ts)
- [`.omp/hooks/post/template-compliance-hint.ts`](.omp/hooks/post/template-compliance-hint.ts)

**Context cost:** Hooks are loaded once and remain in context for their subscribed events. Keep hook logic minimal to avoid context bloat.

---

### 6. Tools

**What it is:** TypeScript modules that expose new callable tools to the agent. Unlike built-in tools, custom tools have custom input/output schemas.

**When to use:**
- You want to expose a capability by name (`tool:my-tool`)
- The capability has structured input/output
- The logic requires TypeScript (not expressible as a prompt)
- The capability wraps an external system or script

**When NOT to use:**
- The capability is a single prompt (use a command or skill instead)
- The capability is purely reactive (use a post-hook instead)
- A built-in tool already does what you need

**Format:** `.omp/tools/<name>/index.ts`

```typescript
import { OmpTool } from '@oh-my-pi/sdk';

interface MyToolInput {
  target: string;
  fix?: boolean;
}

interface MyToolResult {
  success: boolean;
  output: string;
}

export const myTool: OmpTool<MyToolInput, MyToolResult> = async (
  input: MyToolInput
): Promise<OmpToolResult<MyToolResult>> => {
  const { target, fix = false } = input;
  
  try {
    // Implement tool logic
    const output = await runMyProcess(target, fix);
    return { success: true, data: { success: true, output } };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : String(error),
    };
  }
};

export const metadata = {
  name: 'my-tool',
  description: 'Does something useful',
  version: '1.0.0',
  parameters: {
    type: 'object',
    properties: {
      target: { type: 'string', description: 'Target to process' },
      fix: { type: 'boolean', description: 'Attempt auto-fix', default: false },
    },
    required: ['target'],
  },
};
```

**Examples in this repo:**
- [`.omp/tools/template-audit/`](.omp/tools/template-audit/)

**Context cost:** Tools are loaded into the agent's tool list. Each tool adds to startup context proportional to its metadata size.

---

## Common Scenarios

### "I want to enforce X"

**Before picking a mechanism, ask:**
- Does X need to prevent specific text patterns? → **Rule (TTSR)**
- Does X apply whenever a certain file is edited? → **Rule (scope)**
- Does X need to inspect full file context? → **Hook (pre)**
- Does X need to prompt the user? → **Hook (pre)**

### "I want to automate Y"

- Y is a multi-step workflow → **Skill**
- Y is a simple transformation → **Tool**
- Y should happen after something → **Hook (post)**

### "I want to add capability Z"

- Z is a specialist that reviews/generates content → **Agent**
- Z is a reusable prompt → **Command**
- Z is a complete workflow with scripts → **Skill**
- Z is a callable function with structured I/O → **Tool**

---

## Migration Path

Extensions can grow beyond their original type. Here's when to migrate:

| From | To | When |
|------|-----|------|
| Command | Skill | The workflow gains steps or conditional logic |
| Skill | Tool | The workflow becomes pure function with structured I/O |
| Rule (TTSR) | Hook (pre) | Simple pattern match needs full file inspection |
| Rule | Skill | The "don't do X" needs to explain how to do X correctly |
| Tool | Agent | The function needs judgment and multi-step reasoning |

---

## Directory Structure Summary

```
.omp/
├── agents/           # Named sub-agents
│   └── *.md
├── commands/         # Chat prompt templates
│   └── *.md
├── skills/           # Packaged capabilities
│   └── <name>/
│       ├── SKILL.md
│       ├── scripts/
│       └── references/
├── rules/            # Convention enforcement
│   └── *.md
├── hooks/            # Lifecycle interceptors
│   ├── pre/
│   └── post/
└── tools/            # Custom callable tools
    └── <name>/
        └── index.ts
```

---

## Further Reading

- [Oh My Pi documentation](https://github.com/can1357/oh-my-pi/tree/main/docs)
- [agentskills.io/specification](https://agentskills.io/specification)
- [agents.md](./docs/agent-files-guide.md#b-agentsmd)
- [SKILL.md](./docs/agent-files-guide.md#d-skillmd)
