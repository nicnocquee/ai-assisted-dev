# Evidence: T-0003 — flow-status shows dates and open-task trail

## Status

ready-for-review

## Linked commits

| Kind                | SHA                                      | Notes                                             |
| ------------------- | ---------------------------------------- | ------------------------------------------------- |
| Implementation HEAD | 5b1224d15fbdbb80f551f995b477962851116ae8 | Branch task/T-0003-task-history-status at evidence |
| Evidence pack       | (filled after evidence commit)           | This folder                                       |

## What changed

- `skills/flow-status/SKILL.md` dashboard always lists Created / Started / Done or Cancelled for every task
- Full Status log (timestamp + state) is required only for tasks that are not `done` and not `cancelled`
- Closed tasks are dates only; shipped shows Done; cancelled shows Cancelled

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
| how to start if not running | n/a — open the skill file in the steps |

## Seeded demo data

### Credentials

| Role | Username / email | Password |
| ---- | ---------------- | -------- |
| n/a  | n/a              | n/a      |

### Fixture inventory

- None. Verification is reading `skills/flow-status/SKILL.md`.

## Human verification steps

1. Open `.worktrees/T-0003/skills/flow-status/SKILL.md` (branch `task/T-0003-task-history-status`)
2. Confirm **All tasks (dates)** includes Created, Started, Done, Cancelled for every task
3. Confirm shipped tasks show Done not Cancelled, and cancelled tasks show Cancelled not Done
4. Confirm **Open tasks (full trail)** requires the full Status log and forbids collapsing to last line only
5. Confirm closed tasks (`done` / `cancelled`) are dates only — no full trail

### Expected outcomes

- Steps 2–3: date columns and Done vs Cancelled
- Steps 4–5: full trail only while the task is open

## Screenshots

None. This task is documentation.

## Known risks / follow-ups

- Writer skills are T-0002 (parallel branch)
- `docs/features/task-history.md` still says flow-status is “after T-0003”; update that line when this ships if you want the stakeholder doc current

## Verifier attestation

- Verifier agent: parent (docs-only)
- Environment cleaned with db-reset before seed: n/a
- All acceptance criteria observed: yes
