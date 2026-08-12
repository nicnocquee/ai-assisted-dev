---
name: flow-plan
description: >-
  Turn a stakeholder feature request into auditable flow tasks in tasks/
  with acceptance criteria, seed requirements, dependencies, and commits.
  Drills down with clarifying questions first so the plan contains no
  invented scope. Use when planning features, splitting work, creating
  tasks, or when the user says flow-plan / plan this feature / break this
  into tasks.
---

# flow-plan

Convert a feature request into ledger tasks. Stakeholder provides intent; you produce the plan in git.

**You do not fill gaps.** If a product detail is not in the request, the repo, or a stakeholder answer, it is unknown — ask, then stop. Do not write task files until the drill-down gate is passed.

## Read first

- Project `PROJECT.md`
- `tasks/TASKS.md`
- Flow reference: task-format, conventions (from the flow install root under `reference/`)
- TS/JS standards for planning if language is TypeScript or JavaScript

## Preconditions

- Prefer `flow-init` completed (PROJECT.md + tasks/ present). If missing, run flow-init first.

## Workflow

```
Plan progress:
- [ ] 1. Inspect repo + capture only what was said
- [ ] 2. Drill down — no assumptions (STOP until locked)
- [ ] 3. Restate locked outcome
- [ ] 4. Draft task breakdown
- [ ] 5. Mark dependencies for safe parallelism
- [ ] 6. Write task files + ledger rows
- [ ] 7. Commit each task (or one plan commit with all tasks)
- [ ] 8. Present plan for stakeholder confirmation before heavy build
```

### 1. Inspect, then capture (do not invent)

Read enough to ask grounded questions:

- `PROJECT.md`, ledger, related `docs/`
- Existing screens, APIs, models, and seed data that this request might touch

Cite what you found (paths, current behavior). Then write a **facts-only** capture:

- Quotes / bullets from the stakeholder message
- Observable current behavior from the repo
- Explicitly labeled **Unknown** items — never rewrite an unknown as a decision

Do not "restate the outcome" yet. A restatement that adds who, where, confirmations, empty states, or labels is a draft full of assumptions.

### 2. Drill down — hard gate

**Do not** draft acceptance criteria, pick copy, choose task splits, or create `task.md` files until every product unknown is answered.

#### What you may decide vs what you must ask

| Decide from repo / later engineering notes   | Must ask if not already explicit                                            |
| -------------------------------------------- | --------------------------------------------------------------------------- |
| Files, modules, test names, internal types   | Who can do it (role, auth, guest vs logged-in)                              |
| Matching an existing pattern already in code | When / where (screen, moment, entry point)                                  |
| Conventional commit / ledger bookkeeping     | Observable done (what they see or can do)                                   |
| TS/JS standards checklist                    | Confirm vs instant, undo, permissions                                       |
|                                              | Empty, already-done, error, and denied paths that change what the user sees |
|                                              | In vs out of scope                                                          |
|                                              | Seed data for verification (who logs in, which rows exist)                  |
|                                              | Any label, copy, or control name you would put in acceptance criteria       |

If you would write it in **Acceptance criteria**, **Stakeholder verification scenario**, or **Seed requirements**, and the stakeholder did not say it, it is a question.

#### How to ask

1. List the unknowns you would otherwise invent.
2. Ask **2–4 questions per round**. Prefer the `AskQuestion` tool (concrete options + they can pick Other). If the tool is unavailable, ask in prose.
3. **STOP and wait.** Do not continue the workflow, do not propose tasks, do not "meanwhile draft."
4. After answers, drop resolved items and ask the leftovers. Repeat until the unknown list is empty.
5. Do not ask what you can read in the repo. Do not ask the stakeholder to pick files, run commands, or write code.

Frame questions in stakeholder language (what a person sees and can do), not implementation.

Skip the gate only when a written unknown-list is empty — every needed product fact is already in this conversation or cited from the repo. "Just build it" does not skip unanswered product questions; it only skips the final `flow-work` approval later.

### 3. Restate locked outcome

One paragraph the stakeholder can correct: who benefits, what they can do when done, what they will see in the empty/error cases you locked, out of scope.

If they correct anything, return to step 2. Do not proceed on a disputed restatement.

### 4. Break into tasks

Prefer small vertical slices:

- API + domain + test for a unit of behavior
- UI + test for that behavior
- Avoid tasks like "write all tests later"

Each task needs:

- Clear acceptance criteria (stakeholder language — **only locked facts**)
- Stakeholder verification scenario (summary)
- Seed requirements (users, products, rows) so evidence can be self-contained
- Engineering notes (implementation; may be inferred from the repo)
- Dependencies

Record confirmed answers in the task Summary / Acceptance criteria so `flow-work` does not re-invent them.

### 5. Dependencies and parallelism

- Tasks that edit the same core files should chain (depends on)
- Independent modules → no deps (safe parallel `flow-work`)
- Record deps in `task.md` and the `Depends on` ledger column

### 6. IDs, files, ledger

**Pre-write check:** scan every planned acceptance criterion and seed row. If any line is not a locked fact or a repo-cited current behavior, convert it to a question and return to step 2.

1. Next ID = max existing `T-NNNN` + 1 (start at `T-0001`)
2. Slug = short kebab-case title
3. Create `tasks/T-NNNN-slug/task.md` from task-format template
4. Append row to `TASKS.md` with status `planned`

Acceptance criteria must be checkable by a non-coder when following evidence later.

#### TS/JS projects

Every task's Engineering notes / checklist **must** include:

- JSDoc on every new or modified function
- DI for collaborators with production defaults
- Co-located `.test.ts` / `.test.js` with 100% coverage of new logic
- Kebab-case new filenames
- Lint + TypeScript errors resolved before `ready-for-evidence`

### 7. Commit

Preferred: one commit per task file:

```
task(T-0001): create empty-cart task
```

Or single:

```
task: plan <feature-name> (T-0001..T-0003)
```

### 8. Present to stakeholder

Show table:

| ID  | Title | Depends on | Parallel-safe? |
| --- | ----- | ---------- | -------------- |

Ask for approval before launching `flow-work` (unless they already said "just build it").

## Example: empty cart

Request: "I want users to empty their cart."

Unknowns to ask (do not assume):

- Who — any logged-in shopper, only the cart owner, guests?
- Where — cart page only, or also a header/minicart?
- Confirm vs instant — one click, or confirm first?
- Already empty — hide the control, disable it, or still allow a no-op?
- Undo — none, toast undo, or restore from history?
- Seed — which demo user, how many lines in the cart?

After those are locked, tasks might be:

1. `T-0001` domain + API clearCart + unit tests + seed hook
2. `T-0002` UI empty-cart control (depends on T-0001 if API first)

Or one vertical task if the change is tiny.

Seed requirements on the task covering verification — only what was confirmed (or already in `PROJECT.md` demo account):

- demo user + password
- products
- cart lines for that user

## Do not

- Create vague tasks ("improve cart")
- Invent copy, confirmations, empty/error behavior, permissions, or seed rows
- Write `task.md` / `TASKS.md` before the drill-down gate is passed
- Continue planning while questions are unanswered
- Leave seed requirements empty when the feature is user-facing
- Start coding in flow-plan (that is flow-work)
- Ask the stakeholder to choose files, run commands, or write code
