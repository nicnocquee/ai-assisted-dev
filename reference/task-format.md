# Task format and ledger

Tasks are the auditable unit of work. Every status change and spec change is committed to git.

## Layout

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

Transitions are logged in the task's Status log with ISO timestamp and commit SHA when available.

## TASKS.md columns

```markdown
# Task ledger

| ID     | Title      | Status  | Branch                 | Worktree | Evidence | Merge SHA | Depends on |
| ------ | ---------- | ------- | ---------------------- | -------- | -------- | --------- | ---------- |
| T-0001 | Empty cart | planned | task/T-0001-empty-cart |          |          |           |            |
```

Keep this table sorted by ID ascending. Update it whenever status/branch/evidence/merge changes and **commit the update**.

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

| When (UTC)           | Status  | Note         | Commit  |
| -------------------- | ------- | ------------ | ------- |
| 2026-01-01T00:00:00Z | planned | Task created | abc1234 |
```

## Creating a task (flow-plan)

Do not create files until `flow-plan` has finished its drill-down gate (no invented product facts).

1. Assign next ID
2. Write `tasks/T-NNNN-slug/task.md`
3. Append row to `TASKS.md`
4. Commit: `task(T-NNNN): create <slug> task`

## Parallelism and dependencies

- Independent tasks may run in parallel
- If task B needs task A's API/types, set `Depends on: T-NNNN` and do not start B until A is `done`
- Prefer splitting so dependencies stay minimal

## Updating status

1. Edit Status field in `task.md`
2. Append Status log row
3. Update `TASKS.md` row
4. Commit with appropriate type (`chore`, `task`, `feat`, etc.)
