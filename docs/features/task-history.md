# Task state history

Every flow task records **when its state changed**. You can see that without reading git log.

## On the task file

`tasks/T-NNNN-slug/task.md` has a **Status log**: each row is a UTC timestamp and a state name. No notes. No commit SHAs.

Lifecycle names match the Status field (`planned`, `in_progress`, `blocked`, `ready-for-evidence`, `evidence-ready`, `in-review`, `done`, `cancelled`).

Two extra names appear **only in the log**:

- `verify-failed` — evidence did not pass
- `sent-back` — you sent the task back from review

After either of those, the next row is the real Status the task moved to.

## On the ledger

`tasks/TASKS.md` keeps the current Status plus four dates:

| Date        | Meaning                                      |
| ----------- | -------------------------------------------- |
| Created     | When the task file was written               |
| Started     | Most recent time work moved to `in_progress` |
| Done        | When it shipped                              |
| Cancelled   | When it was abandoned                        |

Blank means that moment has not happened. Done and Cancelled are never both filled.

Never started → Started blank. Cancelled before start → Created and Cancelled only. Shipped → Created, Started, and Done.

## On flow-status

Every task shows Created / Started / Done or Cancelled. Open tasks also show the full log. Closed tasks (`done` or `cancelled`) show dates only.

Writer skills and the dashboard are updated in T-0002 and T-0003; this document describes the contract in `reference/task-format.md`.
