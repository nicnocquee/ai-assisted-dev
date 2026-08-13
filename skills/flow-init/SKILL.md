---
name: flow-init
description: >-
  Scaffold a repository for the Ship-Fast flow system: write PROJECT.md,
  create tasks/docs/evidence folders, verify declared commands, first commit.
  Use when initializing flow on a project, setting up agent workflows, or
  when the user says flow-init / set up flow / prepare this repo for agents.
---

# flow-init

Prepare an application repository so flow agents can work without inventing commands.

## Read first

Resolve the flow repo root from this skill's real path (symlink target), then read:

- `reference/project-contract.md`
- `reference/conventions.md`

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
- [ ] 3. Write PROJECT.md
- [ ] 4. Scaffold tasks/, docs/, evidence/
- [ ] 5. Update .gitignore
- [ ] 6. Verify key commands
- [ ] 7. Commit scaffold
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

### 3. Write PROJECT.md

Use the template in project-contract.md. Fill **real** commands. Never leave fakes.

Required command rows: `install`, `dev`, `test`, `lint`, `typecheck`, `seed`, `db-reset` (use `n/a` only when truly not applicable, with note).

Declare:

- base_url / default_port
- env_files
- at least one demo account for review
- agent notes for seed locations

### 4. Scaffold ledger folders

Create if missing:

```
tasks/TASKS.md
docs/.gitkeep
evidence/.gitkeep
```

`tasks/TASKS.md` starter:

```markdown
# Task ledger

| ID | Title | Status | Created | Started | Done | Cancelled | Branch | Worktree | Evidence | Merge SHA | Depends on |
|----|-------|--------|---------|---------|------|-----------|--------|----------|----------|-----------|------------|
```

### 5. .gitignore

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

### 6. Verify commands

From `PROJECT.md`:

1. Run `install` if deps not present
2. Run `test` (or create a minimal passing suite if none)
3. Confirm `lint` / `typecheck` if not `n/a`
4. Confirm `seed` and `db-reset` exist and succeed when a DB is part of the stack — for greenfield without DB yet, document deferral **and** create stub scripts that exit 0 with a clear message until real data exists
5. Start `dev` briefly or health-check so Runtime base_url is honest

If a command fails, fix the project or update `PROJECT.md` — do not commit broken contracts.

### 7. Commit

```
chore(flow): initialize flow scaffold and PROJECT.md
```

Include: `PROJECT.md`, `tasks/`, `docs/`, `evidence/`, `.gitignore` updates, any seed stubs.

## Output to stakeholder

Report:

1. Where `PROJECT.md` lives and key commands
2. Demo account credentials (if any)
3. Next step: `flow-plan` with their feature request

## Do not

- Skip verification of commands
- Ask the stakeholder to write `PROJECT.md` or run install
- Assume stack details not present in repo or conversation
