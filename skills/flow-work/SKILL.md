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
- Flow `reference/conventions.md` and `reference/task-format.md` (especially **Dev server ports**)
- Agent definition `flow-builder` (when launching a subagent)

## Inputs

- Task ID `T-NNNN` (or title resolve to ID)
- Optional: force serial vs parallel note from plan

## Workflow

```
Work progress:
- [ ] 1. Check dependencies done
- [ ] 2. Create branch + worktree
- [ ] 3. Assign dedicated PORT + base_url
- [ ] 4. Status → in_progress (commit)
- [ ] 5. Implement via flow-builder (or inline)
- [ ] 6. Tests + lint/typecheck green
- [ ] 7. Docs under docs/
- [ ] 8. Status → ready-for-evidence (commit)
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

Record `PORT` / `BASE_URL` in the task status log (or builder prompt). Start the app only as:

```bash
PORT="$PORT" <dev command from PROJECT.md>
```

Never start two tasks on the same port. On `EADDRINUSE`, re-pick upward — do not reuse `default_port`.

### 4. Mark in progress

Update task.md status + status log + TASKS.md columns (Branch, Worktree).

Commit on the **task branch** (from inside worktree):

```
chore(T-NNNN): start work
```

### 5. Build

Prefer launching the **flow-builder** agent scoped to the worktree path with a prompt that includes:

- Task acceptance criteria and seed requirements (for later)
- PROJECT.md commands
- **Assigned `PORT` and `BASE_URL`** (use for any local smoke check; do not bind `default_port`)
- Convention: commit every logical unit; never ask stakeholder to run commands
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

Write/update:

- `docs/features/<slug>.md` (required for user-facing work)
- API docs if endpoints added

Commit:

```
docs(T-NNNN): document <feature>
```

### 8. ready-for-evidence

Update task status fields + ledger. Commit:

```
chore(T-NNNN): mark ready-for-evidence
```

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
- Leave uncommitted work when finishing a stage
- Skip docs
- Ask the stakeholder to run install/test/dev
- Mark ready-for-evidence with red tests
- Start `dev` on `default_port` when another flow task may already be using it
