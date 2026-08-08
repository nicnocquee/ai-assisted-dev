# Dry-run: empty-cart mini shop

This directory is a **standalone git repository** used to prove the Ship-Fast flow loop end-to-end.

## Proven trail

| Stage | Result |
|-------|--------|
| flow-init | `PROJECT.md`, `tasks/`, `docs/`, `evidence/` committed |
| flow-plan | `T-0001` empty-cart task in ledger |
| flow-work | Worktree `.worktrees/T-0001` on `task/T-0001-empty-cart` |
| flow-evidence | Seeded user/products/cart; EVIDENCE.md + screenshots committed |
| flow-ship | `--no-ff` merge + ledger Merge SHA + worktree removed |

### Audit pointers (demo shop commits)

See `git log --graph` inside this folder for:

- `task(T-0001): create empty-cart task`
- `docs(T-0001): document empty cart behavior`
- `evidence(T-0001): ...`
- `ship(T-0001): merge empty-cart into main`
- `ship(T-0001): close task ledger`

Evidence: [evidence/T-0001/EVIDENCE.md](shop/evidence/T-0001/EVIDENCE.md)

## Stakeholder try-it (after agents left the app seed ready)

From `demos/shop` (agents normally do this for you):

1. `npm install && npm run db:reset && npm run seed && npm run dev`
2. Open http://localhost:3456
3. Login: `demo@shop.test` / `demo1234`
4. Cart has 3 items → **Empty cart** → empty state
