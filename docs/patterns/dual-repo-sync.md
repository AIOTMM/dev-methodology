# Pattern: Dual-repo sync

> When code spans 2+ repos that must deploy together. Single source of
> truth is THE pattern; the rest are mechanics.

## Architecture

```
Repo A: Strategy logic
Repo B: Production infrastructure (cron, daemons, deploy scripts)

Bind-mount: A's `code/bin/` → B's `/app/bin/` (read-only)

Shared truth: GitHub Project containing issues from BOTH repos
              + META issue per repo, two-way linked
```

## Truth synchronization rules

### Rule 1 — Project board is canonical

If an issue isn't on the Project board, it doesn't exist for cross-repo
planning. Add via:

```bash
gh project item-add <PROJ> --owner <OWNER> --url <issue-url>
```

### Rule 2 — META issues are two-way linked

Repo A META body cites Repo B META URL and vice versa. Each comment update
to one MUST cite the other:

```
## 🔄 Sync update YYYY-MM-DD

Cross-ref: AIOTMM/<repoB>#<METAb> (their last update: <hash>)

Our state: <summary>
Their state (per their META): <summary>
Alignment: ✅ or ❌ <description>
```

### Rule 3 — Bind-mount direction is one-way

Repo A code flows TO Repo B via bind-mount. Never the reverse. Repo B
never pushes to Repo A. If Repo B needs to suggest a Repo A change, it
opens an issue on Repo A — not a PR, not a direct push.

### Rule 4 — Commit cadence is independent

Repo A's commit cadence is its own. Repo B same. Cross-repo sync points
are EXPLICIT (e.g. "after Repo A pushes commit X, Repo B pulls + restarts
container Y").

### Rule 5 — Release tags coordinate

```
Repo A: v1.5.0-rc1
Repo B: v1.5.0-rc1   (same version string, different repos)

Both deploy synchronously to staging. Repo B's deploy reads Repo A's
tag in its CI pipeline to confirm version alignment.
```

## Session structure for dual-repo work

Per `multi-session-coordination.md`:

```
SPEC-CO (Coordinator)
├── Strategies (works in Repo A)
└── OB-Dev (works in Repo B)
```

Each implementer session NEVER pushes to the other repo. SPEC-CO arbitrates
when work in A reveals a needed change in B (or vice versa).

## Common pitfalls

### Pitfall 1: divergent versions

Repo A at v1.5.2-rc1, Repo B at v1.5.0-rc3. Operator confused. Fix:
both repos tagged with same version on same day. Sync at every minor.

### Pitfall 2: silent bind-mount drift

Repo A pushes new commit; bind-mount serves new code; Repo B not notified.
Fix: Repo B's deploy pipeline reads `cat /app/bin/.git-version` against
expected and alerts on mismatch.

### Pitfall 3: cross-repo issue duplication

Same bug filed in both repos because the fix touches both. Fix: file in
the OWNING repo, mirror in the other with `[mirror from owner-repo#N]`
prefix.

## Real precedent

AIOT v15.5 Sprint-P: `agent-5.2-binance-perp` (Repo A, Strategies) +
`AIOT-MVP` (Repo B, infra). 45 items in Project #19. META issues #327 ↔
#1773 two-way linked. Bind-mount: Strategies `code/bin/` → `/app/bin/`.
0 merge conflicts over 3-day parallel sprint.

## Self-validate

- [ ] Project board contains issues from BOTH repos
- [ ] Each repo has META issue, both pinned
- [ ] META issues two-way linked
- [ ] Bind-mount direction documented
- [ ] Version tags aligned at minor (or explicit mismatch rationale)
