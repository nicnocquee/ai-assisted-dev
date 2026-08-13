# T-0003: flow-status shows dates and open-task trail

## Status

in-review

## Summary

The flow-status dashboard always shows Created / Started / Done or Cancelled for every task, and shows the full timestamped trail only for tasks that are not done or cancelled.

## Acceptance criteria

- [x] Every task on the dashboard shows Created, Started, and either Done or Cancelled (blank if that moment has not happened)
- [x] Tasks that are not `done` and not `cancelled` also show the full Status log (timestamp + state)
- [x] Tasks that are `done` or `cancelled` do not show the full trail — dates only
- [x] A cancelled task shows the Cancelled date, not Done; a shipped task shows Done, not Cancelled

## Stakeholder verification scenario

1. Open the updated `skills/flow-status/SKILL.md`
2. Confirm the dashboard tables include Created / Started / Done or Cancelled for every task
3. Confirm full trail is required only for open tasks
4. Confirm closed tasks are dates-only

## Seed requirements

None. This is documentation in the flow install repo.

## Engineering notes

- Depends on T-0001 for column and log meanings
- Edit `skills/flow-status/SKILL.md` only: add date columns to the dashboard tables; add a “History” / trail section for open tasks; keep “Last status log” from becoming the only history for open work
- Safe to run in parallel with T-0002 (different files)
- Not a TypeScript/JavaScript project — no JSDoc / DI / unit-test checklist

## Dependencies

- T-0001

## Branch

task/T-0003-task-history-status

## Worktree

.worktrees/T-0003

## Evidence

evidence/T-0003/EVIDENCE.md

## Merge SHA

(after ship)

## Status log

| When (UTC)           | State              |
| -------------------- | ------------------ |
| 2026-08-13T02:36:23Z | planned            |
| 2026-08-13T02:46:56Z | in_progress        |
| 2026-08-13T02:48:29Z | ready-for-evidence |
| 2026-08-13T02:49:29Z | evidence-ready     |
| 2026-08-13T03:36:19Z | in-review          |
