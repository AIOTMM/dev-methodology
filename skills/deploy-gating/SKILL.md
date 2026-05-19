---
name: deploy-gating
description: Execute S7 gated waterfall (G1-G9) for production deploy. Strict gate-by-gate progression with operator-typed sign-offs at non-mechanical gates.
type: skill
---

# Skill: deploy-gating

## When to invoke

- After S6 7-round review complete
- Production-bound code only
- Operator present for G3, G8

## Execution

Per `docs/stages/07-deploy-qa.md`, sequential:

1. **G1** rc-tag (5min)
2. **G2** Stage-0 sanity (15min)
3. **G3** Operator decisions signed (30-45min, operator-typed)
4. **G4** Calibration ±tolerance (30-60min)
5. **G5** 24h soak SOAK-COMPLETE (passive)
6. **G6** Paper-week green (7 days passive)
7. **G7** Flip-script + dual-path auth (4-11h authoring)
8. **G8** Sequential LIVE flip per feature (operator-typed phrase)
9. **G9** Post-flip 24h monitoring (passive)

## NEVER

- NEVER skip gates
- NEVER manual SQL flip (G7 script required)
- NEVER parallel-flip multiple features (G8 sequential)
- NEVER skip G9 monitor

## Acceptance

- All 9 gates passed in order
- Each gate has acceptance test + audit log
- Operator-typed sign-offs preserved (GPG-signed commits)
- Post-flip 24h zero RED alarms

## Real precedent

AIOT v15.5: G1-G6 ready by Day 14, G7 OP-7 script authored Day 8-12,
G8 sequential flips Day 22 / 29 / 36, G9 24h green per flip.
