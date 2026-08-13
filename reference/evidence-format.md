# Evidence pack format

Evidence is how agents prove work without requiring the stakeholder to set anything up. Every finished task ships with an evidence pack that links to the implementation commit SHA. When `PROJECT.md` → Flow artifacts has `track_in_git: yes` (default if missing), the pack is committed. When `track_in_git: no`, write the pack under the resolved `EVIDENCE_DIR` and do not commit it.

## Layout

Resolve `EVIDENCE_DIR` first (`reference/conventions.md` → Flow artifacts). Relative to that directory:

```
evidence/
└── T-NNNN/
    ├── EVIDENCE.md
    ├── screenshots/          # optional but strongly preferred
    │   ├── 01-login.png
    │   └── 02-cart-full.png
    └── logs/                 # optional capturable outputs
        └── test-output.txt
```

## Hard requirements

1. **Linked commit** — `Implementation commit` field must be a real SHA from the task branch
2. **Evidence commit** — when `track_in_git` is `yes`, commit the pack as `evidence(T-NNNN): ...` so the pack itself has a SHA. When `no`, skip that commit and set Evidence pack SHA to `n/a (artifacts not tracked in git)`
3. **Seeded readiness** — after following Start commands, the human must not need to create data
4. **Credentials** — demo username and password in plain text (demo-only)
5. **Step-by-step** — numbered verification that a non-developer can follow
6. **Observed truth** — screenshots/logs must match what the verifier actually ran; do not invent

## EVIDENCE.md template

```markdown
# Evidence: T-NNNN — <title>

## Status

ready-for-review

## Linked commits

| Kind                | SHA                     | Notes                                    |
| ------------------- | ----------------------- | ---------------------------------------- |
| Implementation HEAD | <sha>                   | Branch task/T-NNNN-slug at evidence time |
| Evidence pack       | <sha after self-commit> | This folder                              |

## What changed

- Short bullet list of user-visible and technical changes
- Link to docs: docs/features/<slug>.md

## Automated checks

| Check     | Command           | Result                |
| --------- | ----------------- | --------------------- |
| test      | <from PROJECT.md> | pass / fail + summary |
| lint      | ...               | pass / n/a            |
| typecheck | ...               | pass / n/a            |

Artifacts: logs/test-output.txt (if captured)

## Local runtime setup (already done by agents if marked running)

| Item                        | Value                                              |
| --------------------------- | -------------------------------------------------- |
| base_url                    | http://localhost:<actual-port>                     |
| seed command                | npm run seed                                       |
| db-reset command            | npm run db:reset                                   |
| agent left app running      | yes / no                                           |
| how to start if not running | `PORT=<actual-port> <dev command from PROJECT.md>` |

## Seeded demo data

### Credentials

| Role | Username / email | Password |
| ---- | ---------------- | -------- |
| demo | demo@shop.test   | demo1234 |

### Fixture inventory

- Products: Mug ($12), Shirt ($28), Stickers ($5)
- Cart for demo user: all three products, qty 1 each
- Other notes: ...

## Human verification steps

1. Ensure app is running at base_url (start with `<dev>` if needed)
2. Open base_url
3. Log in with the credentials above
4. Navigate to **Cart**
5. Confirm you see 3 line items
6. Click **Empty cart** and confirm when asked
7. Confirm cart shows 0 items / empty state

### Expected outcomes

- Step 5: three products listed with correct names/prices
- Step 7: empty state message “Your cart is empty”

## Screenshots

| Step | File                          | Description       |
| ---- | ----------------------------- | ----------------- |
| 3    | screenshots/01-login.png      | After login       |
| 5    | screenshots/02-cart-full.png  | Cart with 3 items |
| 7    | screenshots/03-cart-empty.png | After empty       |

## Known risks / follow-ups

- (none, or non-blocking notes)

## Verifier attestation

- Verifier agent: flow-verifier
- Environment cleaned with db-reset before seed: yes/no
- All acceptance criteria observed: yes/no
- If no: list failures and return to builder
```

## Verifier rules

- Prefer **db-reset then seed** so environment is known
- Prefer capturing screenshots via browser tools when possible
- If verification fails: do **not** mark evidence ready; append Status log `verify-failed`, then Status `blocked` or `in_progress` with its own row (no notes on the Status log)
- Never invent screenshots or test pass results

## Example domain packing (empty cart)

Seed must create:

1. User account the human can log into
2. Catalog products
3. Cart rows binding user ↔ products

Human steps must start from login — not from "first create an account…".
