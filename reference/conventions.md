# Flow conventions

Agents and skills must follow these rules in every project that has been `flow-init`'d.

## Stakeholder rule (non-negotiable)

The human is a **stakeholder only**:

- Never ask them to write code, edit files, or run commands.
- Agents install, run, seed, test, commit, and merge.
- The human only observes, reviews evidence, and approves or rejects ships.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): short imperative summary
```

| Type | Use |
|------|-----|
| `feat` | User-facing feature work |
| `fix` | Bug fix |
| `test` | Tests only |
| `docs` | Documentation only |
| `chore` | Tooling, config, scaffold |
| `refactor` | No behavior change |
| `task` | Create/update task ledger entries |
| `evidence` | Evidence pack for a task |
| `ship` | Merge / close bookkeeping |

Rules:

- Scope is the task id when one exists: `feat(T-0001): empty cart endpoint`
- Commit after every logical unit of work (not only at the end)
- Never leave the worktree dirty when pausing or finishing a task stage
- Prefer many small commits over one large one

### Examples

```
task(T-0001): create empty-cart feature task
feat(T-0001): add clearCart repository method
test(T-0001): cover clearCart edge cases
docs(T-0001): document empty-cart API
evidence(T-0001): seed demo cart + verification walkthrough
ship(T-0001): merge empty-cart into main
```

## Branches

```
task/T-NNNN-slug
```

Examples: `task/T-0001-empty-cart`, `task/T-0012-checkout-tax`

- One task → one branch
- Branch created from the default branch (usually `main`)
- Never work features on `main` directly

## Worktrees

Path (relative to repo root):

```
.worktrees/T-NNNN
```

Rules:

- One worktree per in-progress task
- All code for that task is written inside the worktree
- Add `.worktrees/` to `.gitignore`
- Remove worktree after successful ship (or after cancel)

### Create / remove

```bash
git worktree add .worktrees/T-0001 -b task/T-0001-empty-cart main
# ... work ...
git worktree remove .worktrees/T-0001
```

## Documentation

Every shipped task updates product docs under `docs/`:

| Path | Contents |
|------|----------|
| `docs/features/<slug>.md` | What the feature does, who uses it, how to try it |
| `docs/api/<slug>.md` | Endpoints / contracts if applicable |
| `docs/adr/` | Architecture decisions when justified |

Docs are committed as part of the task branch, not as an afterthought.

## Code quality gates (always)

Before marking implementation `ready-for-evidence`:

1. All tests green (`PROJECT.md` → `test`)
2. Lint/typecheck green if declared (`lint`, `typecheck`)
3. New public functions documented (JSDoc for TS/JS)
4. Tests exist for new logic (100% coverage target for new units in TS/JS)
5. Dependency injection for collaborators when project standards require it
6. New files use kebab-case names when project standards require it

## Parallelism

- Flow-plan may spawn multiple independent tasks
- Tasks with overlapping file ownership get dependencies declared in `task.md`
- Orchestrator only starts a task when dependencies are `done`
- Independent tasks run in parallel via separate worktrees and subagents

## Forbidden

- Asking the stakeholder to run seed/dev/test
- Shipping without an evidence pack linked to a commit
- Force-pushing shared history without explicit stakeholder request
- Merging with fast-forward only (`--no-ff` required for ship)
