# PROJECT.md contract

`PROJECT.md` is the single source of truth for how agents interact with a repo. Skills never hard-code a stack; they read this file and run the declared commands.

## Required sections

```markdown
# Project: <name>

## Stack

- language:
- framework:
- database:
- test_runner:
- package_manager:

## Commands

| Name      | Command | Notes                              |
| --------- | ------- | ---------------------------------- |
| install   | ...     | Fresh deps                         |
| dev       | ...     | Start local app                    |
| test      | ...     | Unit/integration suite             |
| lint      | ...     | Style / static analysis (or `n/a`) |
| typecheck | ...     | Typecheck (or `n/a`)               |
| seed      | ...     | Seed demo/review data              |
| db-reset  | ...     | Wipe + migrate DB for clean verify |

## Runtime

- base_url:
- default_port:
- env_files:

## Seed / demo accounts

| Role | Username / email | Password | Purpose                          |
| ---- | ---------------- | -------- | -------------------------------- |
| demo | ...              | ...      | Human review of shipped features |

## Notes for agents

- (paths for migrations, seed scripts, auth, special env vars)
```

## Rules for agents

1. **Discover, don't invent.** If a command is missing or fails, update `PROJECT.md` after fixing it; do not invent alternate commands silently.
2. **Verify on init.** `flow-init` must run each declared command (or a dry-equivalent) and only commit once commands are truthful.
3. **Prefer declared seeds.** Feature evidence must use `seed` and document credentials in both seed output and `EVIDENCE.md`.
4. **Stack-agnostic.** Do not assume Node/Python/etc. without reading Stack.
5. **Ports.** Never start parallel task worktrees on the same `default_port`. Assign `default_port + N` (task number from `T-NNNN`), scan upward if busy, start with `PORT=<port> <dev>`, and document the actual `base_url` in evidence. See `reference/conventions.md` → Dev server ports.

## Template (copy into apps)

```markdown
# Project: my-app

## Stack

- language: TypeScript
- framework: Next.js
- database: PostgreSQL (Prisma)
- test_runner: Vitest
- package_manager: npm

## Commands

| Name      | Command          | Notes                |
| --------- | ---------------- | -------------------- |
| install   | npm install      |                      |
| dev       | npm run dev      | serves base_url      |
| test      | npm test         | unit + integration   |
| lint      | npm run lint     |                      |
| typecheck | npx tsc --noEmit |                      |
| seed      | npm run seed     | idempotent preferred |
| db-reset  | npm run db:reset | migrate + seed       |

## Runtime

- base_url: http://localhost:3000
- default_port: 3000
- env_files: .env, .env.local

## Seed / demo accounts

| Role | Username / email | Password | Purpose              |
| ---- | ---------------- | -------- | -------------------- |
| demo | demo@example.com | demo1234 | Feature verification |

## Notes for agents

- Prisma schema: prisma/schema.prisma
- Seed: prisma/seed.ts
- Keep seed passwords in docs/env examples as non-production only
```

## Minimal scaffold when unknown

If the project is greenfield empty:

1. Ask the stakeholder only for product name + preferred stack (if they care).
2. Otherwise default only enough to make a runnable demo, then write an accurate `PROJECT.md`.
3. Never leave placeholder commands that do not work.
