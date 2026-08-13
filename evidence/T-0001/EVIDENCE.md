# Evidence: T-0001 — Task history format

## Status

ready-for-review

## Linked commits

| Kind                | SHA                                      | Notes                                              |
| ------------------- | ---------------------------------------- | -------------------------------------------------- |
| Implementation HEAD | 859d140e25c8a33cb6fe67356bc18fa5d24b1c96 | Branch task/T-0001-task-history-format at evidence |
| Evidence pack       | 58a9aa1f489b6a031cd8abfe635c245252a40ac0 | This folder                                        |

## What changed

- `reference/task-format.md` Status log is timestamp + state only; extra log names `verify-failed` and `sent-back`; ledger dates Created / Started / Done / Cancelled with empty-case table
- `skills/flow-init/SKILL.md` starter `TASKS.md` uses those date columns
- Stakeholder doc: [docs/features/task-history.md](../../docs/features/task-history.md)

## Automated checks

| Check     | Command | Result                                  |
| --------- | ------- | --------------------------------------- |
| test      | n/a     | No PROJECT.md; this repo is skills/docs |
| lint      | n/a     | No PROJECT.md                           |
| typecheck | n/a     | No PROJECT.md                           |

Artifacts: logs/test-output.txt

## Local runtime setup (already done by agents if marked running)

| Item                        | Value                                    |
| --------------------------- | ---------------------------------------- |
| base_url                    | n/a — no app                             |
| seed command                | n/a — seed requirements: none            |
| db-reset command            | n/a                                      |
| agent left app running      | no                                       |
| how to start if not running | n/a — open the files listed in the steps |

## Seeded demo data

### Credentials

| Role | Username / email | Password |
| ---- | ---------------- | -------- |
| n/a  | n/a              | n/a      |

### Fixture inventory

- None. Verification is reading markdown in this worktree.

## Human verification steps

1. Open `reference/task-format.md` in this repo (branch `task/T-0001-task-history-format`, or this worktree `.worktrees/T-0001`)
2. Find **Status log**: confirm columns are only `When (UTC)` and `State` (no Note, no Commit)
3. Confirm `verify-failed` and `sent-back` are listed as **log-only** and the Status field table is still the existing lifecycle list
4. Confirm **Ledger dates**: Created = task file written; Started = latest `in_progress`; Done and Cancelled separate; only one filled; blank = has not happened
5. Confirm the empty-case table: never started → Started blank; cancelled before start → Created + Cancelled only; shipped → Created + Started + Done, Cancelled blank
6. Open `skills/flow-init/SKILL.md` and confirm the starter `TASKS.md` header includes Created, Started, Done, Cancelled
7. Confirm the example `task.md` template Status log matches timestamp + state only, and the example `TASKS.md` row includes the date columns

### Expected outcomes

- Step 2: two-column Status log in both the rules and the template
- Step 3: log-only names are not in the Status field table
- Steps 4–5: date meanings and empty cases match what we locked
- Steps 6–7: init starter and template match the contract

## Screenshots

None. This task is documentation; there is no UI to capture.

## Known risks / follow-ups

- Writer skills (`flow-plan`, `flow-work`, `flow-evidence`, `flow-ship`, agents) still mention notes/SHAs on the Status log — that is T-0002
- `flow-status` dashboard does not yet show dates or the open-task trail — that is T-0003

## Verifier attestation

- Verifier agent: parent (docs-only; no app to run)
- Environment cleaned with db-reset before seed: n/a
- All acceptance criteria observed: yes
- If no: list failures and return to builder
