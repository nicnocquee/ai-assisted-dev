# Task format and ledger

Tasks are the auditable unit of work. Every status change and spec change is written to the ledger. When `PROJECT.md` → Flow artifacts has `track_in_git: yes` (the default if the section is missing), those writes are committed to git. When `track_in_git: no`, write the same files under the resolved `TASKS_DIR` and do not commit them.

## Layout

Resolve `TASKS_DIR` first (`reference/conventions.md` → Flow artifacts). Relative to that directory:

```
tasks/
├── TASKS.md                 # index / ledger
└── T-NNNN-slug/
    └── task.md              # full task record
```

## Task IDs

- Format: `T-NNNN` zero-padded, incrementing from existing max in `TASKS.md`
- Slug: kebab-case short title (`empty-cart`)
- Folder: `T-NNNN-slug/`
- Branch: `task/T-NNNN-slug`
- Worktree: `.worktrees/T-NNNN`
- Evidence: `evidence/T-NNNN/`

## Lifecycle statuses

The **Status** field on `task.md` and in `TASKS.md` uses only these values:

| Status               | Meaning                                            |
| -------------------- | -------------------------------------------------- |
| `planned`            | Task file created; not started                     |
| `in_progress`        | Worktree active; building                          |
| `blocked`            | Waiting on dependency or external answer           |
| `ready-for-evidence` | Implementation + tests + docs done                 |
| `evidence-ready`     | Evidence pack committed and ready for human review |
| `in-review`          | Stakeholder reviewing evidence                     |
| `done`               | Merged; ledger has merge SHA                       |
| `cancelled`          | Abandoned; keep history                            |

## Status log

Every state change is appended to the task's Status log. Each row is **When (UTC)** (ISO-8601) and **State** only — no note column, no commit column.

Log `State` is either a lifecycle status (same names as the Status field) or one of these **log-only** names (they never appear in the Status field):

| Log-only name   | When to append                                     |
| --------------- | -------------------------------------------------- |
| `verify-failed` | Evidence / verify did not pass                     |
| `sent-back`     | Stakeholder rejected review and sent the task back |

After a log-only name, append a second row for the lifecycle status the task actually moves to (`in_progress`, `blocked`, `ready-for-evidence`, or `cancelled`).

## TASKS.md columns

```markdown
# Task ledger

| ID     | Title      | Status  | Created              | Started | Done | Cancelled | Branch                 | Worktree | Evidence | Merge SHA | Depends on |
| ------ | ---------- | ------- | -------------------- | ------- | ---- | --------- | ---------------------- | -------- | -------- | --------- | ---------- |
| T-0001 | Empty cart | planned | 2026-01-01T00:00:00Z |         |      |           | task/T-0001-empty-cart |          |          |           |            |
```

Keep this table sorted by ID ascending. Update it whenever status, dates, branch, evidence, or merge changes. **Commit the update** when `track_in_git` is `yes`; otherwise write the file only.

### Ledger dates

| Column    | Meaning                                     | When to fill                                      |
| --------- | ------------------------------------------- | ------------------------------------------------- |
| Created   | When the task file was written              | Once, at create; never overwrite                  |
| Started   | Latest time the task moved to `in_progress` | Every move to `in_progress` (overwrites previous) |
| Done      | When the task was shipped (`done`)          | On ship; leave blank otherwise                    |
| Cancelled | When the task was abandoned (`cancelled`)   | On cancel; leave blank otherwise                  |

Blank means that moment has not happened. Done and Cancelled are separate; **only one is filled**.

| Situation              | Created | Started | Done   | Cancelled |
| ---------------------- | ------- | ------- | ------ | --------- |
| Planned, never started | filled  | blank   | blank  | blank     |
| Cancelled before start | filled  | blank   | blank  | filled    |
| Shipped                | filled  | filled  | filled | blank     |
| Cancelled after start  | filled  | filled  | blank  | filled    |

## task.md template

```markdown
# T-0001: Empty cart

## Status

planned

## Summary

Stakeholders can empty all items from their shopping cart in one action.

## Acceptance criteria

- [ ] Logged-in user with items in cart sees an "Empty cart" control on the cart page
- [ ] Confirming empty cart leaves the cart with zero items
- [ ] Empty cart is safe when the cart is already empty
- [ ] Unit tests cover success and empty cases
- [ ] Feature docs updated under docs/features/

## Stakeholder verification scenario

What the human will do after evidence (high level). Detailed steps belong in EVIDENCE.md.

1. Log in as seeded user
2. Open cart and confirm pre-seeded items
3. Empty cart and confirm zero items

## Seed requirements

Data the evidence seeder must create:

- User: demo@shop.test / demo1234
- At least 3 products in catalog
- Those products pre-added to the demo user's cart

## Engineering notes

- (files expected to touch, API shape, constraints)

### TS/JS standards checklist (include when project language is TS/JS)

- [ ] JSDoc on every new or modified function
- [ ] Collaborators accepted via dependency injection with production defaults
- [ ] Co-located unit tests (`.test.ts` / `.test.js`) targeting 100% coverage of new logic
- [ ] Kebab-case filenames for new files
- [ ] Lint and TypeScript errors resolved before ready-for-evidence

## Dependencies

- none | T-0002 | ...

## Branch

task/T-0001-empty-cart

## Worktree

.worktrees/T-0001

## Evidence

(evidence/T-0001/EVIDENCE.md once exists)

## Merge SHA

(after ship)

## Status log

| When (UTC)           | State   |
| -------------------- | ------- |
| 2026-01-01T00:00:00Z | planned |
```

## Creating a task (flow-plan)

Do not create files until `flow-plan` has finished its drill-down gate (no invented product facts).

1. Assign next ID
2. Write `tasks/T-NNNN-slug/task.md` with Status `planned` and a first Status log row (`When` = now UTC, `State` = `planned`)
3. Append a `TASKS.md` row: Status `planned`, Created = that same timestamp, Started / Done / Cancelled blank
4. If `track_in_git` is `yes`, commit: `task(T-NNNN): create <slug> task`. If `no`, skip the commit.

## Parallelism and dependencies

- Independent tasks may run in parallel
- If task B needs task A's API/types, set `Depends on: T-NNNN` and do not start B until A is `done`
- Prefer splitting so dependencies stay minimal

## Updating status

1. Edit Status field in `task.md` (lifecycle status only)
2. Append a Status log row: `When (UTC)` + `State` only. For `verify-failed` or `sent-back`, append that log-only row, then a lifecycle-status row
3. Update `TASKS.md`: Status, and Created / Started / Done / Cancelled as defined above
4. If `track_in_git` is `yes`, commit with appropriate type (`chore`, `task`, `feat`, etc.). If `no` and the change is only ledger files, skip the commit.
