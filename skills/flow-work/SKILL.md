---
name: flow-work
description: >-
  Implement one flow task in a git worktree: branch, tests, docs, regular
  commits, status updates, then ready-for-evidence. Use when executing a
  task, building a feature slice, or when the user says flow-work / implement
  T-NNNN / build the task.
---

# flow-work

Execute a single ledger task end-to-end inside an isolated worktree. Stakeholder does not run tools.

## Read first

- `PROJECT.md`
- `tasks/T-NNNN-slug/task.md` and `tasks/TASKS.md`
- Flow `reference/conventions.md` and `reference/task-format.md`
- Agent definition `flow-builder` (when launching a subagent)

## Inputs

- Task ID `T-NNNN` (or title resolve to ID)
- Optional: force serial vs parallel note from plan

## Workflow

```
Work progress:
- [ ] 1. Check dependencies done
- [ ] 2. Create branch + worktree
- [ ] 3. Status → in_progress (commit)
- [ ] 4. Implement via flow-builder (or inline)
- [ ] 5. Tests + lint/typecheck green
- [ ] 6. Docs under docs/
- [ ] 7. Status → ready-for-evidence (commit)
- [ ] 8. Hand off to flow-evidence
```

### 1. Dependencies

If `Depends on` lists tasks not `done`, stop and report blocked. Do not start.

### 2. Worktree + branch

From **main repo root** (not another worktree):

```bash
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/head 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo main)
git fetch 2>/dev/null || true
git worktree add ".worktrees/T-NNNN" -b "task/T-NNNN-slug" "${DEFAULT_BRANCH}"
```

If branch already exists without worktree:

```bash
git worktree add ".worktrees/T-NNNN" "task/T-NNNN-slug"
```

Ensure `.worktrees/` is gitignored.

### 3. Mark in progress

Update task.md status + status log + TASKS.md columns (Branch, Worktree).

Commit on the **task branch** (from inside worktree):

```
chore(T-NNNN): start work
```

### 4. Build

Prefer launching the **flow-builder** agent scoped to the worktree path with a prompt that includes:

- Task acceptance criteria and seed requirements (for later)
- PROJECT.md commands
- Convention: commit every logical unit; never ask stakeholder to run commands
- TS/JS standards when applicable (JSDoc, DI, co-located tests, kebab-case, lint/types)

Builder loop:

1. Write failing tests when practical
2. Implement
3. Run `test` (and lint/typecheck)
4. Commit conventionals
5. Repeat until acceptance criteria met in code

Parallelism: orchestrator may run multiple flow-work instances on independent tasks as **background subagents**, each with its own worktree. Never two builders in one worktree.

### 5. Quality gate

All must pass before next status:

- `PROJECT.md` test command
- lint/typecheck if not `n/a`
- Acceptance criteria implementable without further build (or document remainder only if out of scope)

### 6. Documentation

Write/update:

- `docs/features/<slug>.md` (required for user-facing work)
- API docs if endpoints added

Commit:

```
docs(T-NNNN): document <feature>
```

### 7. ready-for-evidence

Update task status fields + ledger. Commit:

```
chore(T-NNNN): mark ready-for-evidence
```

### 8. Handoff

Invoke **flow-evidence** for the same task (same worktree). Do not wait for the stakeholder to start the app.

## Parallel orchestration (parent chat)

When multiple tasks are parallel-safe:

1. Create all worktrees first
2. Launch one builder subagent per task
3. Collect completions; queue dependents after predecessors are `done` (or after merge if needed)

## Do not

- Implement on `main`
- Leave uncommitted work when finishing a stage
- Skip docs
- Ask the stakeholder to run install/test/dev
- Mark ready-for-evidence with red tests
