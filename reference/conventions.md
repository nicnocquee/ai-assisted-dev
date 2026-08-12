# Flow conventions

Agents and skills must follow these rules in every project that has been `flow-init`'d.

## Stakeholder rule (non-negotiable)

The human is a **stakeholder only**:

- Never ask them to write code, edit files, or run commands.
- Agents install, run, seed, test, commit, and merge.
- The human only observes, reviews evidence, and approves or rejects ships.

## Agent models (per role)

Each custom agent pins its own model in YAML frontmatter. Skills launch the named agent and **do not pass a model override** unless the stakeholder named one.

| Agent           | Role          | Model                        | Why                                                    |
| --------------- | ------------- | ---------------------------- | ------------------------------------------------------ |
| `flow-builder`  | Implement     | `composer-2.5[fast=false]`   | Coding, tests, docs                                    |
| `flow-verifier` | Evidence / QA | `composer-2.5[fast=true]`    | Seed, run app, screenshots — speed over deep reasoning |
| `flow-reviewer` | Diff review   | `claude-opus-5[effort=high]` | Correctness, security, missing tests                   |

The parent orchestrator (the chat that runs `flow-plan` / `flow-work` / `flow-evidence` / `flow-ship`) uses whatever model you picked in Cursor. Skills run there; only delegated subagents use the table above.

To change a role's model, edit `model:` in `agents/<name>.md` (the install symlink picks it up). Cursor falls back if that model is blocked or not on the plan.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): short imperative summary
```

| Type       | Use                               |
| ---------- | --------------------------------- |
| `feat`     | User-facing feature work          |
| `fix`      | Bug fix                           |
| `test`     | Tests only                        |
| `docs`     | Documentation only                |
| `chore`    | Tooling, config, scaffold         |
| `refactor` | No behavior change                |
| `task`     | Create/update task ledger entries |
| `evidence` | Evidence pack for a task          |
| `ship`     | Merge / close bookkeeping         |

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

| Path                      | Contents                                          |
| ------------------------- | ------------------------------------------------- |
| `docs/features/<slug>.md` | What the feature does, who uses it, how to try it |
| `docs/api/<slug>.md`      | Endpoints / contracts if applicable               |
| `docs/adr/`               | Architecture decisions when justified             |

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

## Dev server ports (parallel worktrees)

Multiple agents must **never** all bind `PROJECT.md` `default_port`. Each task owns a dedicated port.

### Assignment

1. Read `default_port` from `PROJECT.md` Runtime.
2. Parse task number `N` from `T-NNNN` (e.g. `T-0001` → `1`, `T-0012` → `12`).
3. Candidate: `default_port + N`.
4. If that port is already listening, scan upward until free (cap: candidate + 100).
5. Record the chosen port + `base_url` (`http://localhost:<port>`) for evidence and handoffs.

Inline picker (run from the app repo):

```bash
pick_flow_port() {
  local default_port="$1" task_id="$2"
  local num candidate port max
  num=$((10#${task_id#T-}))
  candidate=$((default_port + num))
  max=$((candidate + 100))
  port=$candidate
  while lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; do
    port=$((port + 1))
    (( port > max )) && { echo "No free port near $candidate" >&2; return 1; }
  done
  echo "$port"
}
PORT="$(pick_flow_port 3000 T-0001)"   # use PROJECT.md default_port
```

Or resolve the flow install via the `flow-work` skill symlink:

```bash
FLOW_ROOT="$(cd "$(dirname "$(readlink -f ~/.cursor/skills/flow-work)")/.." && pwd)"
"${FLOW_ROOT}/reference/scripts/pick-flow-port.sh" <default_port> T-NNNN
```

### Starting the app

Prefer the `PORT` env var (works for Next, Vite, many Node servers):

```bash
PORT=<port> <dev command from PROJECT.md>
```

If the stack ignores `PORT`, use its explicit flag (e.g. `next dev -p <port>`) and document that in `PROJECT.md` agent notes.

On `EADDRINUSE`, bump the port and retry — do not fall back to `default_port`.

Always put the **actual** `base_url` in evidence and in the stakeholder handoff (never assume the PROJECT.md default).

### When to assign

- **flow-work**: assign when creating the worktree / launching builders; pass `PORT` + `base_url` into builder and evidence prompts.
- **flow-evidence / flow-verifier**: re-confirm the port is free (or re-pick) before `dev`; never start two tasks on the same port.

## Forbidden

- Asking the stakeholder to run seed/dev/test
- Shipping without an evidence pack linked to a commit
- Force-pushing shared history without explicit stakeholder request
- Merging with fast-forward only (`--no-ff` required for ship)
