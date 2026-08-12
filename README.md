# Ship-Fast Agent System ("flow")

Personal Cursor skills and agents that let AI agents plan, build, verify, and ship features while you act as **stakeholder only** — no coding, no terminal.

## What you get

- **Auditable task ledger** in each app repo (`tasks/`)
- **Parallel work** via git worktrees (one task per worktree, one dedicated `dev` port per task)
- **Regular commits** with conventional messages
- **Always-on documentation** under `docs/`
- **Committed evidence packs** with seeded data, credentials, screenshots, and step-by-step human verification
- **Stakeholder ship gate** — you review evidence, then agents merge
- **Per-role models** — builder, verifier, and reviewer each pin their own model (see below)

## Models (per role)

The chat you type in uses whatever you pick in Cursor. Delegated agents do not inherit that unless you override them.

| Agent           | Model                               |
| --------------- | ----------------------------------- |
| `flow-builder`  | `composer-2.5` (standard, not fast) |
| `flow-verifier` | `composer-2.5` fast                 |
| `flow-reviewer` | `claude-opus-5` high effort         |

Change a pin by editing `model:` in `agents/<name>.md`.

## Install

```bash
cd /path/to/ai-assisted-dev
./install.sh
```

This symlinks skills into `~/.cursor/skills/` and agents into `~/.cursor/agents/`.

## Workflow (in any app repo)

| Skill           | When                                                                            |
| --------------- | ------------------------------------------------------------------------------- |
| `flow-init`     | First time on a project — writes `PROJECT.md`, scaffolds folders                |
| `flow-plan`     | You describe a feature — agent asks until nothing is assumed, then writes tasks |
| `flow-work`     | Agents implement a task in a worktree                                           |
| `flow-evidence` | Agents seed data, run the app, produce review evidence                          |
| `flow-ship`     | You approve → merge, close task, clean worktree                                 |
| `flow-status`   | Dashboard of all tasks / worktrees / evidence                                   |

### Example

> "I want users to empty their cart."

1. Agent runs **flow-plan** → clarifying questions, then tasks with acceptance criteria
2. Agent runs **flow-work** (possibly in parallel worktrees)
3. Agent runs **flow-evidence** → seeds user + products + cart items, writes login credentials and step-by-step verification
4. You open the app locally with the provided credentials and walk through
5. You approve → **flow-ship** merges and records the merge SHA in the ledger

## Stack-agnostic

Every project has a `PROJECT.md` contract declaring commands (`dev`, `test`, `lint`, `seed`, `db-reset`). Skills read the contract; they never assume a framework.

## Layout of this repo

```
skills/          # Cursor skills (flow-*)
agents/          # Builder, verifier, reviewer subagents
reference/       # Conventions, formats, templates
install.sh       # Symlink installer
```

## Uninstall

```bash
./install.sh --uninstall
```

## Dry-run (already exercised)

`demos/shop` is a nested git demo that ran the full loop once (empty cart):

- Ledger: `demos/shop/tasks/`
- Evidence + screenshots: `demos/shop/evidence/T-0001/`
- Notes: [demos/README.md](demos/README.md)

Stakeholder review credentials (demo only): `demo@shop.test` / `demo1234` @ http://localhost:3456
