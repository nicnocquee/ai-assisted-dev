---
name: flow-plan
description: >-
  Turn a stakeholder feature request into auditable flow tasks in tasks/
  with acceptance criteria, seed requirements, dependencies, and commits.
  Use when planning features, splitting work, creating tasks, or when the
  user says flow-plan / plan this feature / break this into tasks.
---

# flow-plan

Convert a feature request into ledger tasks. Stakeholder provides intent; you produce the plan in git.

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
- [ ] 1. Restate stakeholder outcome
- [ ] 2. Draft task breakdown
- [ ] 3. Mark dependencies for safe parallelism
- [ ] 4. Write task files + ledger rows
- [ ] 5. Commit each task (or one plan commit with all tasks)
- [ ] 6. Present plan for stakeholder confirmation before heavy build
```

### 1. Restate outcome

One paragraph: who benefits, what they can do when done, out of scope.

### 2. Break into tasks

Prefer small vertical slices:

- API + domain + test for a unit of behavior
- UI + test for that behavior
- Avoid tasks like "write all tests later"

Each task needs:

- Clear acceptance criteria (stakeholder language)
- Stakeholder verification scenario (summary)
- Seed requirements (users, products, rows) so evidence can be self-contained
- Engineering notes
- Dependencies

### 3. Dependencies and parallelism

- Tasks that edit the same core files should chain (depends on)
- Independent modules → no deps (safe parallel `flow-work`)
- Record deps in `task.md` and the `Depends on` ledger column

### 4. IDs, files, ledger

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

### 5. Commit

Preferred: one commit per task file:

```
task(T-0001): create empty-cart task
```

Or single:

```
task: plan <feature-name> (T-0001..T-0003)
```

### 6. Present to stakeholder

Show table:

| ID | Title | Depends on | Parallel-safe? |
|----|-------|------------|----------------|

Ask for approval before launching `flow-work` (unless they already said "just build it").

## Example: empty cart

Tasks might be:

1. `T-0001` domain + API clearCart + unit tests + seed hook
2. `T-0002` UI empty-cart control (depends on T-0001 if API first)

Or one vertical task if the change is tiny.

Seed requirements on the task covering verification:

- demo user + password
- products
- cart lines for that user

## Do not

- Create vague tasks ("improve cart")
- Leave seed requirements empty when the feature is user-facing
- Start coding in flow-plan (that is flow-work)
