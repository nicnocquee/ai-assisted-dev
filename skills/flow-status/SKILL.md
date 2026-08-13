---
name: flow-status
description: >-
  Report a stakeholder dashboard of all flow tasks, worktrees, evidence packs,
  and blockers. Use when checking progress, status, what is ready to review,
  or when the user says flow-status / dashboard / what is in progress.
---

# flow-status

Read-only (except optional refreshing stale ledger fields if they are clearly wrong and you commit the fix — prefer report only).

## Read

- Resolve artifact dirs first (`reference/conventions.md` → Flow artifacts)
- `$TASKS_DIR/TASKS.md` and each `$TASKS_DIR/T-*/task.md` (Status log + dates)
- `git worktree list`
- `$EVIDENCE_DIR/**/EVIDENCE.md` existence/status
- Default branch recent `ship(` commits (optional)
- Report whether artifacts are git-tracked or local-only (`TRACK_IN_GIT`)

Date columns and Status log rules: `reference/task-format.md`.

## Output format

Present a clear dashboard:

### Summary

| Metric                     | Count |
| -------------------------- | ----- |
| planned                    |       |
| in_progress                |       |
| ready-for-evidence         |       |
| evidence-ready / in-review |       |
| done                       |       |
| blocked / cancelled        |       |

### All tasks (dates)

Every task, including `done` and `cancelled`. Show Created, Started, and **either** Done **or** Cancelled (blank if that moment has not happened). A shipped task shows Done, not Cancelled. A cancelled task shows Cancelled, not Done.

| ID  | Title | Status | Created | Started | Done | Cancelled |
| --- | ----- | ------ | ------- | ------- | ---- | --------- |

Closed tasks (`done` or `cancelled`) stop here — **dates only, no full trail**.

### Open tasks (full trail)

For every task that is **not** `done` and **not** `cancelled`, also show the full Status log (every `When (UTC)` + `State` row). Do not collapse this to “last status log” only.

| ID  | Title | Branch | Worktree exists? | Status log |
| --- | ----- | ------ | ---------------- | ---------- |

Under **Status log**, list the full trail (timestamp + state), not a single last line.

### Ready for stakeholder

| ID  | Title | Evidence path | Credentials (from evidence) | base_url | Created | Started |
| --- | ----- | ------------- | --------------------------- | -------- | ------- | ------- |

### Blocked / waiting

| ID  | Title | Depends on / reason | Created | Started |
| --- | ----- | ------------------- | ------- | ------- |

### Live worktrees

Paste sanitized `git worktree list` (paths + branches).

### Suggested next actions

- e.g. “Approve T-0002 via flow-ship”
- e.g. “T-0003 blocked on T-0001 merge”
- e.g. “No PROJECT.md → run flow-init”

## Checks to run

```bash
eval "$(<flow-root>/reference/scripts/resolve-flow-artifacts.sh)"
test -f PROJECT.md && echo "PROJECT.md ok" || echo "MISSING PROJECT.md"
test -f "$TASKS_DIR/TASKS.md" && echo "ledger ok ($TASKS_DIR)" || echo "MISSING ledger"
echo "TRACK_IN_GIT=$TRACK_IN_GIT ARTIFACT_ROOT=$ARTIFACT_ROOT"
git worktree list
# optional: compare TASKS worktree column to real paths
```

## Tone

Stakeholder-friendly. No raw dump of entire task files unless asked. Never ask them to run commands to see status — you ran them.
