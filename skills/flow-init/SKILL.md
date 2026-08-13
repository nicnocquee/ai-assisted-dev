---
name: flow-init
description: >-
  Scaffold a repository for the Ship-Fast flow system: write PROJECT.md,
  choose whether tasks/evidence are committed to git, create artifact
  folders, verify declared commands, first commit.
  Use when initializing flow on a project, setting up agent workflows, or
  when the user says flow-init / set up flow / prepare this repo for agents.
---

# flow-init

Prepare an application repository so flow agents can work without inventing commands.

## Read first

Resolve the flow repo root from this skill's real path (symlink target), then read:

- `reference/project-contract.md`
- `reference/conventions.md` (especially **Flow artifacts**)

Example: if skills live at `<flow-root>/skills/flow-init`, references are at `<flow-root>/reference/`.

## Preconditions

- You may create git repos, files, dirs, and commits.
- Stakeholder never runs setup commands — you do everything.

## Workflow

Copy and track:

```
Init progress:
- [ ] 1. Detect or create git repo
- [ ] 2. Infer stack
- [ ] 3. Ask where flow artifacts live (STOP until answered)
- [ ] 4. Write PROJECT.md
- [ ] 5. Scaffold tasks/, docs/, evidence/ at the chosen location
- [ ] 6. Update .gitignore
- [ ] 7. Verify key commands
- [ ] 8. Commit scaffold (exclude local-only artifacts)
```

### 1. Git repo

```bash
git rev-parse --is-inside-work-tree || git init
```

Ensure a default branch name is known (`main` preferred).

### 2. Infer stack

Inspect:

- `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `Gemfile`, etc.
- Existing README / Makefile / docker-compose
- DB tooling (prisma, drizzle, alembic, rails db)

If empty greenfield: ask stakeholder only for product intent + optional stack preference. Otherwise choose a minimal runnable stack and own setup end-to-end.

### 3. Artifact git policy (hard gate)

Flow artifacts are the **task ledger** (`tasks/`), **evidence packs** (`evidence/` — screenshots, seed notes, verification steps), and **feature docs** (`docs/`).

**Skip this ask** only when:

- The stakeholder already stated a preference in this conversation, or
- `PROJECT.md` already has a **Flow artifacts** section (re-init: keep it unless they asked to change it)

Otherwise **ask and STOP**. Prefer the `AskQuestion` tool (they can pick Other). Do not scaffold `tasks/`, `evidence/`, or `docs/`, do not write the Flow artifacts section, and do not continue until they answer.

Question:

> Flow writes a task ledger (`tasks/`), evidence packs (`evidence/`: screenshots, seed notes, step-by-step review), and feature docs (`docs/`). Should those be committed to this repo's git history?

Options:

- **A)** Yes — keep `tasks/`, `evidence/`, and `docs/` in the repo and commit them (recommended when you want an audit trail in PRs / clones)
- **B)** No — keep them in the repo but add `tasks/`, `evidence/`, and `docs/` to `.gitignore`
- **C)** No — store them outside the repo at `~/.flow/projects/<slug>/` (slug = repo directory name)

Map the answer:

| Choice | `track_in_git` | `root`                    |
| ------ | -------------- | ------------------------- |
| A      | `yes`          | `repo`                    |
| B      | `no`           | `repo`                    |
| C      | `no`           | `~/.flow/projects/<slug>` |

For C, slug = basename of the repo root, kebab-case, filesystem-safe. Create that directory when scaffolding.

Tell them briefly what the choice means (clones / worktrees / commits), then continue.

### 4. Write PROJECT.md

Use the template in project-contract.md. Fill **real** commands. Never leave fakes.

Required command rows: `install`, `dev`, `test`, `lint`, `typecheck`, `seed`, `db-reset` (use `n/a` only when truly not applicable, with note).

Declare:

- base_url / default_port
- env_files
- at least one demo account for review
- agent notes for seed locations
- **Flow artifacts** with the `track_in_git` and `root` values from step 3

### 5. Scaffold ledger folders

Create `tasks/TASKS.md`, `docs/.gitkeep`, and `evidence/.gitkeep` under the artifact root:

- A / B: `<repo>/tasks`, `<repo>/docs`, `<repo>/evidence`
- C: `~/.flow/projects/<slug>/tasks`, `docs`, `evidence` — do **not** create those folders in the repo

`tasks/TASKS.md` starter (match `reference/task-format.md` columns):

```markdown
# Task ledger

| ID  | Title | Status | Created | Started | Done | Cancelled | Branch | Worktree | Evidence | Merge SHA | Depends on |
| --- | ----- | ------ | ------- | ------- | ---- | --------- | ------ | -------- | -------- | --------- | ---------- |
```

### 6. .gitignore

Ensure ignored:

```
.worktrees/
.env
.env.local
node_modules/
dist/
coverage/
*.log
```

(Adapt to stack; keep `.worktrees/` always.)

If **B** (in-repo, not committed), also add:

```
# Flow artifacts (local only — chosen at flow-init)
/tasks/
/evidence/
/docs/
```

If **C**, do not create those repo folders. You may still add `/tasks/`, `/evidence/`, and `/docs/` as a safety net so a later accidental create is not committed.

If **A**, do **not** ignore `tasks/`, `evidence/`, or `docs/`.

### 7. Verify commands

From `PROJECT.md`:

1. Run `install` if deps not present
2. Run `test` (or create a minimal passing suite if none)
3. Confirm `lint` / `typecheck` if not `n/a`
4. Confirm `seed` and `db-reset` exist and succeed when a DB is part of the stack — for greenfield without DB yet, document deferral **and** create stub scripts that exit 0 with a clear message until real data exists
5. Start `dev` briefly or health-check so Runtime base_url is honest

If a command fails, fix the project or update `PROJECT.md` — do not commit broken contracts.

### 8. Commit

```
chore(flow): initialize flow scaffold and PROJECT.md
```

Always include: `PROJECT.md`, `.gitignore` updates, any seed stubs.

Include `tasks/`, `docs/`, and `evidence/` **only** when `track_in_git` is `yes` (choice A).

Never `git add` gitignored or external artifact folders.

## Output to stakeholder

Report:

1. Where `PROJECT.md` lives and key commands
2. Artifact policy: committed in-repo / gitignored in-repo / stored at `<path>`
3. Demo account credentials (if any)
4. Next step: `flow-plan` with their feature request

## Do not

- Skip verification of commands
- Ask the stakeholder to write `PROJECT.md` or run install
- Assume stack details not present in repo or conversation
- Assume artifacts should be committed — ask (or honor a stated preference)
- Continue past step 3 while the artifact question is unanswered
- Commit `tasks/`, `evidence/`, or `docs/` when `track_in_git` is `no`
