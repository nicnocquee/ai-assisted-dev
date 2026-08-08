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

- `tasks/TASKS.md` and each `tasks/T-*/task.md` if needed
- `git worktree list`
- `evidence/**/EVIDENCE.md` existence/status
- Default branch recent `ship(` commits (optional)

## Output format

Present a clear dashboard:

### Summary

| Metric | Count |
|--------|-------|
| planned | |
| in_progress | |
| ready-for-evidence | |
| evidence-ready / in-review | |
| done | |
| blocked / cancelled | |

### In progress

| ID | Title | Branch | Worktree exists? | Last status log |
|----|-------|--------|------------------|-----------------|

### Ready for stakeholder

| ID | Title | Evidence path | Credentials (from evidence) | base_url |
|----|-------|---------------|-----------------------------|----------|

### Blocked / waiting

| ID | Title | Depends on / reason |
|----|-------|---------------------|

### Live worktrees

Paste sanitized `git worktree list` (paths + branches).

### Suggested next actions

- e.g. “Approve T-0002 via flow-ship”
- e.g. “T-0003 blocked on T-0001 merge”
- e.g. “No PROJECT.md → run flow-init”

## Checks to run

```bash
test -f PROJECT.md && echo "PROJECT.md ok" || echo "MISSING PROJECT.md"
test -f tasks/TASKS.md && echo "ledger ok" || echo "MISSING ledger"
git worktree list
# optional: compare TASKS worktree column to real paths
```

## Tone

Stakeholder-friendly. No raw dump of entire task files unless asked. Never ask them to run commands to see status — you ran them.
