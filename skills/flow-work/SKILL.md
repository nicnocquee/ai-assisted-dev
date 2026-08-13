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

- `PROJECT.md` (including **Flow artifacts**)
- Flow `reference/conventions.md` → **Flow artifacts** and **Dev server ports**
- `$TASKS_DIR/T-NNNN-slug/task.md` and `$TASKS_DIR/TASKS.md`
- Flow `reference/task-format.md`
- Agent definition `flow-builder` (when launching a subagent)

```bash
eval "$(<flow-root>/reference/scripts/resolve-flow-artifacts.sh)"
```

When `TRACK_IN_GIT` is `no`, ledger and docs writes go to the resolved absolute `TASKS_DIR` / `DOCS_DIR` (main worktree or external path) — never to `tasks/` or `docs/` inside the task worktree.

## Inputs

- Task ID `T-NNNN` (or title resolve to ID)
- Optional: force serial vs parallel note from plan

## Workflow

```
Work progress:
- [ ] 1. Check dependencies done
- [ ] 2. Create branch + worktree
- [ ] 3. Assign dedicated PORT + base_url
- [ ] 4. Status → in_progress (commit ledger only if `TRACK_IN_GIT=yes`)
- [ ] 5. Implement via flow-builder (or inline)
- [ ] 6. Tests + lint/typecheck green
- [ ] 7. Docs under $DOCS_DIR
- [ ] 8. Status → ready-for-evidence (commit ledger only if `TRACK_IN_GIT=yes`)
- [ ] 9. Hand off to flow-evidence (pass PORT)
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

### 3. Assign PORT (required for web apps)

Do this **before** launching any subagent that might start `dev`. Parallel worktrees must not share `default_port`.

```bash
DEFAULT_PORT=$(awk '/default_port:/ {print $NF; exit}' PROJECT.md)
pick_flow_port() {
  local default_port="$1" task_id="$2" num candidate port max
  num=$((10#${task_id#T-}))
  candidate=$((default_port + num))
  max=$((candidate + 100))
  port=$candidate
  while lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; do
    port=$((port + 1))
    (( port > max )) && { echo "No free port near $candidate" >&2; return 1; }
  done
  echo "$port"
}
PORT="$(pick_flow_port "$DEFAULT_PORT" T-NNNN)"
BASE_URL="http://localhost:${PORT}"
```

Or use `reference/scripts/pick-flow-port.sh` from the flow install (see conventions).

Pass `PORT` / `BASE_URL` in the **builder prompt** (not the Status log). Start the app only as:

```bash
PORT="$PORT" <dev command from PROJECT.md>
```

Never start two tasks on the same port. On `EADDRINUSE`, re-pick upward — do not reuse `default_port`.

### 4. Mark in progress

1. Set `$TASKS_DIR/.../task.md` Status to `in_progress`
2. Append a Status log row: `When` = now UTC, `State` = `in_progress` (timestamp + state only)
3. Update `$TASKS_DIR/TASKS.md`: Status `in_progress`, **Started** = that timestamp (overwrite if it was set before), Branch, Worktree

If the task cannot start (dependency or missing API), set Status `blocked`, append `blocked`, leave Started as-is (blank if never started).

If `TRACK_IN_GIT` is `yes`, commit on the **task branch** (from inside worktree):

```
chore(T-NNNN): start work
```

If `TRACK_IN_GIT` is `no`, write the ledger files only — do not `git add` `tasks/` or `docs/`.

### 5. Build

Prefer launching the **flow-builder** agent scoped to the worktree path. Do **not** pass a model unless the stakeholder named one — `flow-builder` is pinned to `composer-2.5[fast=false]` (see `reference/conventions.md` → Agent models). Include in the prompt:

- Absolute path to `task.md` (`$TASKS_DIR/T-NNNN-slug/task.md`) and `$TASKS_DIR/TASKS.md`
- Absolute `$DOCS_DIR` for feature docs
- `TRACK_IN_GIT` — if `no`, update ledger/docs on disk and never `git add` `tasks/`, `evidence/`, or `docs/`
- Task acceptance criteria and seed requirements (for later)
- PROJECT.md commands
- **Assigned `PORT` and `BASE_URL`** (use for any local smoke check; do not bind `default_port`)
- Convention: commit every logical unit of **application code** (and docs only if `TRACK_IN_GIT=yes`); never ask stakeholder to run commands
- TS/JS standards when applicable (JSDoc, DI, co-located tests, kebab-case, lint/types)

Builder loop:

1. Write failing tests when practical
2. Implement
3. Run `test` (and lint/typecheck)
4. Commit conventionals
5. Repeat until acceptance criteria met in code

Parallelism: orchestrator may run multiple flow-work instances on independent tasks as **background subagents**, each with its own worktree **and its own PORT**. Never two builders in one worktree. Never two tasks on one port.

### 6. Quality gate

All must pass before next status:

- `PROJECT.md` test command
- lint/typecheck if not `n/a`
- Acceptance criteria implementable without further build (or document remainder only if out of scope)

### 7. Documentation

Write/update under `$DOCS_DIR`:

- `features/<slug>.md` (required for user-facing work)
- API docs if endpoints added

If `TRACK_IN_GIT` is `yes`, commit:

```
docs(T-NNNN): document <feature>
```

If `no`, write the files only — do not `git add` `docs/`.

### 8. ready-for-evidence

1. Set Status `ready-for-evidence`
2. Append Status log row `ready-for-evidence`
3. Update `$TASKS_DIR/TASKS.md` Status (do not fill Done or Cancelled)

If `TRACK_IN_GIT` is `yes`, commit:

```
chore(T-NNNN): mark ready-for-evidence
```

If `no`, write the ledger only.

### 9. Handoff

Invoke **flow-evidence** for the same task (same worktree), passing the assigned `PORT` / `BASE_URL`. Do not wait for the stakeholder to start the app.

## Parallel orchestration (parent chat)

When multiple tasks are parallel-safe:

1. Create all worktrees first
2. Assign a **unique PORT per task** (`default_port + N`, scan up if busy)
3. Launch one builder subagent per task (include that task's PORT in the prompt)
4. Collect completions; queue dependents after predecessors are `done` (or after merge if needed)

## Do not

- Implement on `main`
- Leave uncommitted **application code** when finishing a stage
- Commit `tasks/`, `evidence/`, or `docs/` when `TRACK_IN_GIT` is `no`
- Skip docs
- Ask the stakeholder to run install/test/dev
- Mark ready-for-evidence with red tests
- Start `dev` on `default_port` when another flow task may already be using it
- Write a note column or commit SHA on the Status log
