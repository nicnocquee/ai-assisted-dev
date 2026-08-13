# T-0002: Skills write task history

## Status

done

## Summary

Every skill and agent that creates or changes a task writes the timestamped Status log and the Created / Started / Done / Cancelled ledger dates, using only state names (including `verify-failed` and `sent-back`).

## Acceptance criteria

- [x] Creating a task writes Created (UTC) and a first Status log row `planned`; Started, Done, and Cancelled stay blank
- [x] Moving to `in_progress` appends that row and sets Started to that timestamp (overwrites a previous Started)
- [x] Every other lifecycle change appends a Status log row with that status name
- [x] Failed verify appends `verify-failed`, then the Status field moves to a lifecycle status (`in_progress` or `blocked`) with its own row
- [x] Stakeholder send-back appends `sent-back`, then the Status field moves to `in_progress` or `ready-for-evidence` with its own row
- [x] Shipping fills Done and appends `done`; cancelling fills Cancelled and appends `cancelled`; the other of those two columns stays blank
- [x] No skill or agent writes a note column or a commit column on the Status log
- [x] `flow-plan`, `flow-work`, `flow-evidence`, `flow-ship`, `flow-builder`, `flow-verifier`, and `reference/evidence-format.md` all match these rules

## Stakeholder verification scenario

1. Read the updated skills (plan → work → evidence → ship, plus the two agents)
2. Confirm each status change names the log row and which ledger date to set
3. Confirm failed verify and send-back use the extra names, then a real lifecycle status
4. Confirm nothing still says to write notes or commit SHAs on the Status log

## Seed requirements

None. This is documentation in the flow install repo.

## Engineering notes

- Depends on T-0001 so the contract in `task-format.md` is already the source of truth
- Update: `skills/flow-plan/SKILL.md`, `skills/flow-work/SKILL.md`, `skills/flow-evidence/SKILL.md`, `skills/flow-ship/SKILL.md`, `agents/flow-builder.md`, `agents/flow-verifier.md`, `reference/evidence-format.md` (remove “with log notes”)
- `flow-work` step 4: set Started + append `in_progress`; record PORT in the builder prompt, not as a Status log note
- `flow-evidence` step 8: append `evidence-ready`; fail path: `verify-failed` then `in_progress` or `blocked`
- `flow-ship`: append `in-review`; reject → `sent-back` then `in_progress` or `ready-for-evidence`; close → `done` + Done column; if cancel is documented, `cancelled` + Cancelled column
- Do not edit `skills/flow-status/SKILL.md` (T-0003)
- Not a TypeScript/JavaScript project — no JSDoc / DI / unit-test checklist

## Dependencies

- T-0001

## Branch

task/T-0002-task-history-writers

## Worktree

(removed)

## Evidence

evidence/T-0002/EVIDENCE.md

## Merge SHA

e66cb6e30348edb419018b0a7bcfb361932becc7

## Status log

| When (UTC)           | State              |
| -------------------- | ------------------ |
| 2026-08-13T02:36:23Z | planned            |
| 2026-08-13T02:46:56Z | in_progress        |
| 2026-08-13T02:48:29Z | ready-for-evidence |
| 2026-08-13T02:49:29Z | evidence-ready     |
| 2026-08-13T03:36:19Z | in-review          |
| 2026-08-13T03:37:48Z | done               |
