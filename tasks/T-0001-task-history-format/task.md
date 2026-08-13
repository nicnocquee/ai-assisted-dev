# T-0001: Task history format

## Status

in_progress

## Summary

The written contract for flow tasks records when a task was created, last started, done, or cancelled, and keeps an append-only log of every state name (timestamp + state only).

## Acceptance criteria

- [ ] Opening `reference/task-format.md` shows a Status log with only `When (UTC)` and state — no note column, no commit column
- [ ] The format lists extra log-only names `verify-failed` and `sent-back`; the Status field still uses the existing lifecycle statuses
- [ ] `TASKS.md` column list includes Created, Started, Done, and Cancelled with these meanings: Created = task file written; Started = latest move to `in_progress`; Done and Cancelled are separate and only one is filled; blank means that moment has not happened
- [ ] Never started → Started blank; cancelled before start → Created + Cancelled only; shipped → Created + Started + Done, Cancelled blank
- [ ] `flow-init` starter `TASKS.md` uses the same columns
- [ ] The example task template in `task-format.md` matches this log and these ledger columns

## Stakeholder verification scenario

1. Open `reference/task-format.md` and the `flow-init` starter ledger
2. Confirm the Status log is timestamp + state only
3. Confirm Created / Started / Done / Cancelled are defined as above
4. Confirm `verify-failed` and `sent-back` are log names, not new Status-field values

## Seed requirements

None. This is documentation in the flow install repo.

## Engineering notes

- Edit `reference/task-format.md`: lifecycle table stays; drop “commit SHA when available” from the transitions sentence; replace TASKS.md example columns; replace Status log example; add a short rule for extra log names and ledger date columns (including latest-start overwrite)
- Edit `skills/flow-init/SKILL.md` starter table to add Created, Started, Done, Cancelled (empty cells)
- Do not change writer skills here (T-0002) or `flow-status` (T-0003)
- Not a TypeScript/JavaScript project — no JSDoc / DI / unit-test checklist

## Dependencies

- none

## Branch

task/T-0001-task-history-format

## Worktree

.worktrees/T-0001

## Evidence

(evidence/T-0001/EVIDENCE.md once exists)

## Merge SHA

(after ship)

## Status log

| When (UTC)           | State       |
| -------------------- | ----------- |
| 2026-08-13T02:36:23Z | planned     |
| 2026-08-13T02:38:03Z | in_progress |
