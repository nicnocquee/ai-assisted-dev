---
name: flow-evidence
description: >-
  Build a committed flow evidence pack for a task: db-reset/seed, run app,
  screenshots, test logs, credentials, and human step-by-step verification
  linked to implement commit SHAs. Use after ready-for-evidence, when preparing
  review materials, or when the user says flow-evidence / prove it works.
---

# flow-evidence

Produce observational proof that a task works for a stakeholder without their manual setup.

## Read first

- `PROJECT.md`
- Task file + acceptance criteria + seed requirements
- Flow `reference/evidence-format.md`
- Flow `reference/conventions.md` → **Dev server ports**
- Agent `flow-verifier`

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
- [ ] 6. Write evidence/T-NNNN/EVIDENCE.md
- [ ] 7. Commit evidence pack; record SHAs
- [ ] 8. Status → evidence-ready; hand off flow-ship
```

Prefer delegating steps 2–6 to **flow-verifier**. Parent ensures commits and status updates.

### 1. Implementation SHA

```bash
cd .worktrees/T-NNNN   # or worktree path
git rev-parse HEAD
```

Record as Implementation HEAD.

### 2. Automated checks

Run from worktree using PROJECT.md:

- test → save summary to `evidence/T-NNNN/logs/test-output.txt`
- lint / typecheck if applicable

Failing checks → return task to `in_progress`, notify builder. No fake passes.

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
3. Capture screenshots into `evidence/T-NNNN/screenshots/`
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

From worktree:

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
- TASKS.md Evidence column → `evidence/T-NNNN/EVIDENCE.md`
- Status log row with SHAs

Commit:

```
chore(T-NNNN): mark evidence-ready
```

Present a short review blurb to the stakeholder pointing at the evidence file, credentials, and base_url. Then use **flow-ship**.

## Empty-cart packing example

Seed: user `demo@shop.test` / `demo1234`, ≥3 products, all in cart.

Steps: open app → login → cart has 3 items → Empty cart → empty state.

## Do not

- Mark ready without running seed and checks
- Leave seed requirements as "TBD"
- Invent screenshots or green tests
- Ask the stakeholder to create accounts or seed data
