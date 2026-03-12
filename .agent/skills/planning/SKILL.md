---
name: planning
description: Use when you have a spec or requirements for a multi-step task, before touching code. Adapted from 'writing-plans'.
---

# Writing Plans (Router)

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`

## How to execute this skill (Progressive Context Loading)

For every planning task, follow these steps and read the required context ONLY when you need it:

### Step 1: Plan Structure and Task Granularity
If you are writing an Implementation Plan and need the MD layout, header format, or step-by-step definition:
👉 **READ:** [`references/plan_structure.md`](references/plan_structure.md)

### Step 2: Execution Handoff
After saving the plan, offer the execution choice to the user:

**"Plan complete and saved to `docs/plans/<filename>.md`. Two execution options:**
**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration
**2. Parallel Session (separate)** - Open new session, batch execution with checkpoints
**Which approach?"**
