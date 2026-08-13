# Evidence: T-0002 — Skills write task history

## Status

ready-for-review

## Linked commits

| Kind                | SHA                                      | Notes                                              |
| ------------------- | ---------------------------------------- | -------------------------------------------------- |
| Implementation HEAD | 850b8a0bd06e6dacc808270ea4af46285838d4de | Branch task/T-0002-task-history-writers at evidence |
| Evidence pack       | aa0ecdce66fe6b7bbda9f2db0248f6d207e36fd1 | This folder                                        |

## What changed

- `flow-plan` writes Created + first Status log `planned`; Started / Done / Cancelled blank
- `flow-work` sets Started (overwrite) + `in_progress`; PORT goes in the builder prompt, not the log
- `flow-evidence` / `flow-verifier`: `verify-failed` then `in_progress` or `blocked`; evidence-ready has no SHA on the log
- `flow-ship`: `in-review`; send-back then lifecycle status; ship fills Done; cancel fills Cancelled
- `flow-builder` and `evidence-format.md` match (no notes on the Status log)

## Automated checks

| Check     | Command | Result                                  |
| --------- | ------- | --------------------------------------- |
| test      | n/a     | No PROJECT.md; this repo is skills/docs |
| lint      | n/a     | No PROJECT.md                           |
| typecheck | n/a     | No PROJECT.md                           |

Artifacts: logs/test-output.txt

## Local runtime setup (already done by agents if marked running)

| Item                        | Value                                  |
| --------------------------- | -------------------------------------- |
| base_url                    | n/a — no app                           |
| seed command                | n/a — seed requirements: none          |
| db-reset command            | n/a                                    |
| agent left app running      | no                                     |
| how to start if not running | n/a — open the files listed in steps   |

## Seeded demo data

### Credentials

| Role | Username / email | Password |
| ---- | ---------------- | -------- |
| n/a  | n/a              | n/a      |

### Fixture inventory

- None. Verification is reading markdown in this worktree.

## Human verification steps

1. Open `.worktrees/T-0002` (branch `task/T-0002-task-history-writers`)
2. In `skills/flow-plan/SKILL.md` step 6: confirm Created is set and Started / Done / Cancelled stay blank; first log row is `planned`
3. In `skills/flow-work/SKILL.md`: confirm `in_progress` sets Started (overwrite) and PORT is not written to the Status log
4. In `skills/flow-evidence/SKILL.md` and `agents/flow-verifier.md`: confirm fail path is `verify-failed` then `in_progress` or `blocked`
5. In `skills/flow-ship/SKILL.md`: confirm send-back, Done vs Cancelled, and `done` log row
6. Search those files plus `agents/flow-builder.md` and `reference/evidence-format.md` for a Status log note column or commit-SHA column — there should be none

### Expected outcomes

- Steps 2–5: each transition names the log row and the ledger date
- Step 6: no note/commit columns on the Status log

## Screenshots

None. This task is documentation.

## Known risks / follow-ups

- `flow-status` dashboard is T-0003 (parallel branch)

## Verifier attestation

- Verifier agent: parent (docs-only)
- Environment cleaned with db-reset before seed: n/a
- All acceptance criteria observed: yes
