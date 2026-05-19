# Pattern: Gate-driven deploy

> Production deploy via explicit gates (G1-G9 per S7), not via courage.

## Core invariant

```
Every gate has:
1. An acceptance test (machine-verifiable)
2. A failure escalation path
3. A rollback option
4. An operator-typed sign-off (if non-mechanical)
```

If a "gate" has none of the above, it's not a gate, it's a hope.

## Gate state machine

```
PENDING → IN_PROGRESS → PASSED  → next gate
                     → FAILED  → escalate + RCA + retry
                     → HALTED  → operator decision
```

NEVER skip from PENDING → PASSED. PASSED only after acceptance test runs.

## When to use this pattern

- Production-bound code
- Multi-tenant deploys
- Operator-typed magic phrases involved
- Financial / safety-critical / regulated domains
- Cross-repo coordination required

## Implementation cost

Per gate:
- Acceptance test script: 30-60 min
- Failure escalation runbook: 15-30 min
- Rollback companion: 30-60 min
- Operator runbook update: 15 min

9-gate waterfall (per S7): 12-20h total implementation. Amortizes across
every deploy.

## Anti-pattern: implicit gates

```
# WRONG: "operator should run tests before tag"
# - No enforcement
# - No record
# - Drift possible

# CORRECT: scripted gate (project-implemented per S7 G2)
bash <your-project>/scripts/gate-G2-stage-zero.sh && \
  git tag -a v$VER-rc$N -m "..." && \
  git push origin v$VER-rc$N
```

Real precedent: AIOT v15.5 used `bash tools/v15.5-stage-0-verify.sh` —
naming + path are project-specific; the IDEA of scripted-not-implicit
is what transfers.

## Multi-feature sequential flip

When multiple features ship in same sprint:

```
G1-G6: parallel-OK per feature (each feature has own paper-week)
G7: per-feature flip script (one script per feature, even if shared logic)
G8: SEQUENTIAL — never flip 2 features same day
G9: parallel-OK (each feature monitored independently)
```

Rationale: G8 sequential gives operator observation window between flips.
Flipping 2 same day → if one breaks, hard to attribute root cause.

## Real precedent

AIOT v15.5: 3 features (Pyramid / CVD / BOUNCE) × 3 accounts. Sequential
G8: Day 22 (CVD vinslai) → Day 29 (Pyramid bitabc) → Day 36 (BOUNCE vins2).
Each gets own G9 24h monitor before next opens.
