# T-0002: Skills write task history

## Status

planned

## Summary

Every skill and agent that creates or changes a task writes the timestamped Status log and the Created / Started / Done / Cancelled ledger dates, using only state names (including `verify-failed` and `sent-back`).

## Acceptance criteria

- [ ] Creating a task writes Created (UTC) and a first Status log row `planned`; Started, Done, and Cancelled stay blank
- [ ] Moving to `in_progress` appends that row and sets Started to that timestamp (overwrites a previous Started)
- [ ] Every other lifecycle change appends a Status log row with that status name
- [ ] Failed verify appends `verify-failed`, then the Status field moves to a lifecycle status (`in_progress` or `blocked`) with its own row
- [ ] Stakeholder send-back appends `sent-back`, then the Status field moves to `in_progress` or `ready-for-evidence` with its own row
- [ ] Shipping fills Done and appends `done`; cancelling fills Cancelled and appends `cancelled`; the other of those two columns stays blank
- [ ] No skill or agent writes a note column or a commit column on the Status log
- [ ] `flow-plan`, `flow-work`, `flow-evidence`, `flow-ship`, `flow-builder`, `flow-verifier`, and `reference/evidence-format.md` all match these rules

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

.worktrees/T-0002

## Evidence

(evidence/T-0002/EVIDENCE.md once exists)

## Merge SHA

(after ship)

## Status log

| When (UTC)           | State   |
| -------------------- | ------- |
| 2026-08-13T02:36:23Z | planned |
