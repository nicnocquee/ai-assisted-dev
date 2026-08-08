---
name: flow-ship
description: >-
  Stakeholder review gate for a flow task: present evidence, wait for
  approval, merge with --no-ff, update ledger merge SHA, remove worktree.
  Use when shipping, merging, closing a task, or when the user says
  flow-ship / approve and merge / ship T-NNNN.
---

# flow-ship

Close the loop: human approval → auditable merge → ledger update → cleanup.

## Read first

- `evidence/T-NNNN/EVIDENCE.md`
- Task file + TASKS.md
- `reference/conventions.md`
- Agent `flow-reviewer` (optional pre-check)

## Preconditions

- Status is `evidence-ready` or stakeholder explicitly approves mid-review
- Evidence pack committed and credentials present
- Branch exists and is mergeable into default branch

## Workflow

```
Ship progress:
- [ ] 1. Optional flow-reviewer on the diff
- [ ] 2. Status → in-review; present evidence to stakeholder
- [ ] 3. Wait for explicit approval or change requests
- [ ] 4. On reject: return to builder / new evidence
- [ ] 5. On approve: merge --no-ff into default branch
- [ ] 6. Record merge SHA; status → done; commit ledger on main
- [ ] 7. Remove worktree; report complete trail
```

### 1. Code review (recommended)

Launch **flow-reviewer** on the task branch vs default branch. Fix blocking issues before asking stakeholder to re-verify if needed.

### 2. Present evidence (stakeholder language)

Summarize:

1. What they can try (base_url, left running? start command)
2. Credentials
3. Step-by-step verification list from EVIDENCE.md
4. Link paths: `evidence/T-NNNN/EVIDENCE.md`, docs feature page
5. Implementation + evidence SHAs

Update status to `in-review` and commit on the task branch if not already:

```
chore(T-NNNN): mark in-review for stakeholder
```

### 3. Approval

**Only** proceed to merge after clear approval language ("approve", "ship it", "LGTM", "merge").

Change requests → document in status log, set `in_progress` or `ready-for-evidence`, hand back to flow-work / flow-evidence.

### 4. Merge (--no-ff)

From **main worktree** (repo root, default branch), not inside the task worktree:

```bash
DEFAULT_BRANCH=main   # or from PROJECT / remote HEAD
git checkout "${DEFAULT_BRANCH}"
git pull --ff-only 2>/dev/null || true
git merge --no-ff "task/T-NNNN-slug" -m "ship(T-NNNN): merge <title>

Evidence: evidence/T-NNNN/EVIDENCE.md
Implementation reviewed by stakeholder."
MERGE_SHA=$(git rev-parse HEAD)
```

Never force-push default branch as part of ship.

### 5. Ledger on default branch

Update after merge:

- task.md Status `done`, Merge SHA = `$MERGE_SHA`, status log row
- TASKS.md row: status done, merge SHA filled, worktree cleared

Commit on default branch:

```
ship(T-NNNN): close task ledger
```

### 6. Cleanup

```bash
git worktree remove ".worktrees/T-NNNN" --force 2>/dev/null || git worktree remove ".worktrees/T-NNNN"
# optional branch delete after merge:
git branch -d "task/T-NNNN-slug" 2>/dev/null || true
```

### 7. Stakeholder report

Give the audit trail:

| Field | Value |
|-------|-------|
| Task | T-NNNN |
| Merge SHA | … |
| Evidence | evidence/T-NNNN/EVIDENCE.md |
| Branch | task/T-NNNN-slug (merged) |

## Do not

- Merge without stakeholder approval
- Fast-forward only (use `--no-ff`)
- Drop evidence from history
- Leave orphaned worktrees
- Ask the stakeholder to run `git merge`
