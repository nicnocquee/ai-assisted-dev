---
name: flow-evidence
description: >-
  Build a flow evidence pack for a task: db-reset/seed, run app,
  screenshots, test logs, credentials, and human step-by-step verification
  linked to implement commit SHAs. Commit the pack only when artifacts are
  tracked in git. Use after ready-for-evidence, when preparing
  review materials, or when the user says flow-evidence / prove it works.
---

# flow-evidence

Produce observational proof that a task works for a stakeholder without their manual setup.

## Read first

- `PROJECT.md` (including **Flow artifacts**)
- Flow `reference/conventions.md` → **Flow artifacts** and **Dev server ports**
- Task file + acceptance criteria + seed requirements (`$TASKS_DIR`)
- Flow `reference/evidence-format.md`
- Agent `flow-verifier`

```bash
eval "$(<flow-root>/reference/scripts/resolve-flow-artifacts.sh)"
```

Write the pack under `$EVIDENCE_DIR/T-NNNN/`. When `TRACK_IN_GIT` is `no`, that directory is the main worktree or the external root — not `evidence/` inside the task worktree.

## Preconditions

- Task status is `ready-for-evidence` (or re-run after a failed verify)
- Worktree + branch still exist
- Implementation commits are on the branch

## Workflow

```
Evidence progress:
- [ ] 1. Note implementation HEAD SHA
- [ ] 2. Run quality checks; capture logs
- [ ] 3. db-reset + seed (or seed if no reset)
- [ ] 4. Start app (dev); confirm base_url
- [ ] 5. Walk feature (browser preferred); screenshots
- [ ] 6. Write $EVIDENCE_DIR/T-NNNN/EVIDENCE.md
- [ ] 7. Commit evidence pack if `TRACK_IN_GIT=yes`; record SHAs
- [ ] 8. Status → evidence-ready; hand off flow-ship
```

Prefer delegating steps 2–6 to **flow-verifier**. Do **not** pass a model unless the stakeholder named one — `flow-verifier` is pinned to `composer-2.5[fast=true]` (see `reference/conventions.md` → Agent models). Parent ensures commits (when tracked) and status updates. Pass absolute `$EVIDENCE_DIR` and `$TASKS_DIR` plus `TRACK_IN_GIT` in the verifier prompt.

### 1. Implementation SHA

```bash
cd .worktrees/T-NNNN   # or worktree path
git rev-parse HEAD
```

Record as Implementation HEAD.

### 2. Automated checks

Run from worktree using PROJECT.md:

- test → save summary to `$EVIDENCE_DIR/T-NNNN/logs/test-output.txt`
- lint / typecheck if applicable

Failing checks → append Status log `verify-failed`, then set Status to `in_progress` or `blocked` (append that row too), notify builder. No fake passes. No notes or commit SHAs on the Status log.

### 3. Data readiness

Using PROJECT.md:

1. `db-reset` when available (clean slate)
2. `seed` producing everything in task seed requirements

Seed **must** include login credentials and domain objects the human scenario needs (e.g. cart lines for empty-cart).

If seed is insufficient for the scenario, extend seed scripts in this worktree, re-run, and commit seed changes as part of the task before writing evidence.

### 4. Run the app

Assign a **task-unique port** before starting (see `reference/conventions.md` → Dev server ports). Prefer the PORT passed from flow-work; otherwise:

```bash
DEFAULT_PORT=$(awk '/default_port:/ {print $NF; exit}' PROJECT.md)
# candidate = default_port + N from T-NNNN; scan up if busy
PORT="$(pick_flow_port "$DEFAULT_PORT" T-NNNN)"   # or reference/scripts/pick-flow-port.sh
BASE_URL="http://localhost:${PORT}"
PORT="$PORT" <dev command from PROJECT.md>
```

Confirm the process is reachable at `BASE_URL`. Document that **actual** URL in evidence — never assume PROJECT.md `base_url` if the port differs.

On `EADDRINUSE`, bump port and retry. Do not collide with other worktrees.

Keep the process running when possible so the stakeholder can click immediately. Document:

- app left running? yes/no
- how to start if no (must include `PORT=<port>` or equivalent)

### 5. Observe the feature

With browser automation when UI:

1. Log in as seeded user
2. Navigate to feature surface
3. Capture screenshots into `$EVIDENCE_DIR/T-NNNN/screenshots/`
4. Perform the happy path (e.g. empty cart)
5. Confirm expected outcomes from acceptance criteria

API-only features: capture request/response logs instead of screenshots.

### 6. Write EVIDENCE.md

Follow `reference/evidence-format.md` template completely:

- Linked commits table
- What changed + docs link
- Automated checks table
- Runtime + seed credentials
- Fixture inventory
- Numbered **Human verification steps** starting from open URL / login (no “first create an account”)
- Screenshots table
- Verifier attestation

### 7. Commit evidence

If `TRACK_IN_GIT` is `no`: do not `git add` `$EVIDENCE_DIR` or `$DOCS_DIR`. Set Evidence pack SHA to `n/a (artifacts not tracked in git)`.

If `TRACK_IN_GIT` is `yes`, from worktree:

```bash
git add evidence/T-NNNN docs/  # if docs updated
git commit -m "evidence(T-NNNN): <short what was proven>"
EVIDENCE_SHA=$(git rev-parse HEAD)
```

Patch EVIDENCE.md so Evidence pack SHA is filled (second small commit if needed):

```
evidence(T-NNNN): link evidence commit SHA
```

### 8. Ledger

- Status → `evidence-ready`
- Append Status log row `evidence-ready` (timestamp + state only)
- `$TASKS_DIR/TASKS.md` Evidence column → `$EVIDENCE_DIR/T-NNNN/EVIDENCE.md` (use the path you will show the stakeholder)

If verify fails after a walk: append `verify-failed`, then Status `in_progress` or `blocked` with its own row. Do not mark evidence-ready.

If `TRACK_IN_GIT` is `yes`, commit:

```
chore(T-NNNN): mark evidence-ready
```

If `no`, write the ledger only.

Present a short review blurb to the stakeholder pointing at the evidence file, credentials, and base_url. Then use **flow-ship**.

## Empty-cart packing example

Seed: user `demo@shop.test` / `demo1234`, ≥3 products, all in cart.

Steps: open app → login → cart has 3 items → Empty cart → empty state.

## Do not

- Mark ready without running seed and checks
- Leave seed requirements as "TBD"
- Invent screenshots or green tests
- Ask the stakeholder to create accounts or seed data
