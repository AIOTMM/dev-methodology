# Lessons learned: Sprint-P QA-R1..R7 (2026-05-19)

## Sprint context

AIOT v15.5 Path B: 3 strategy ports + Hummingbot integration + multi-account
LIVE flip prep. Cross-repo (`AIOTMM/agent-5.2-binance-perp` + `AIOTMM/AIOT-MVP`).

## Quantitative outcome

- 7 review rounds (R1-R7)
- 12 CRITICAL bugs found + fixed + regression-tested
- 14 HIGH issues addressed
- 18 audit findings deferred to v15.6 Sprint Q (each as GitHub issue)
- 44 regression tests added (suite 701 → 772)
- 5 sprint commits (R1=e501e38 → R5=fa1e052 → R6=e90beee → R7=1fa9066)
- 23 GitHub issues + 2 milestones + 1 META + 1 Project (Strategies side)
- 22 mirror GitHub issues + 3 milestones + 1 META (OB-Dev side)
- 45 items cross-repo Project board

## Top 5 CRITICAL bugs caught (would have shipped without S6)

1. **F-PYR-02**: Pyramid TP fires on every cross-up. Upstream uses 70/65
   hysteresis. Port fired multiple TPs in oscillation.
2. **F-BOS-02**: BOUNCE exit-side slippage silently dropped. Engine
   `is_sl_like` set didn't match port exit reason strings.
3. **C-R5-A**: SQLite hydration uses `fetchone()` → drops all but 1 position
   for multi-position strategies.
4. **C-R5-C**: `synchronous=FULL` PRAGMA never set → power-loss can lose
   committed close_position_atomic data.
5. **R3 shell injection**: DB content flows through `echo` to telegram via SSH
   → `$(...)` in DB row = command execution on remote.

## Top 3 anti-patterns observed

See `ANTI-PATTERNS.md`.

## What worked

- Per-round adversarial sub-agent dispatch (CRITICAL findings found EVERY round)
- Cross-repo Project + dual META issue
- Operator-decisions v2 strategy×account matrix (vs single-pilot Q1-Q8)
- /A3 7-round review caught regressions that /A1 single review would miss

## What to do differently next sprint

- Run S2 resource confirmation BEFORE writing spec (not after)
- Tag pre-LIVE rc earlier (was day 22, could be day 12 with parallel sprint)
- Cross-session handoff prompts MUST cite META issue numbers (not "the file")

## References

- Strategies META: github.com/AIOTMM/agent-5.2-binance-perp/issues/327
- OB-Dev META: github.com/AIOTMM/AIOT-MVP/issues/1773
- Project: github.com/orgs/AIOTMM/projects/19
- Operator-decisions v2: AIOTMM/AIOT-MVP commit e3a66fb
