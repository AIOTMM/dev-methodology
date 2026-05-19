# Stage 7 — Deploy & QA via Gated Waterfall

> **Goal**: Production-flip via gates, not via courage.
> **Anti-goal**: "Manual SQL UPDATE strategies SET mode='live'" — no audit, no rollback.

## The 9-gate waterfall

Sequential. Each gate must PASS before next opens. Any gate FAIL → halt
+ root-cause + retry gate (not skip).

```
G1 rc-tag → G2 Stage-0 sanity → G3 operator decisions signed
                       ↓
G4 calibration ±tolerance → G5 24h soak SOAK-COMPLETE → G6 paper-week green
                       ↓
G7 flip-script ready (dual-path auth) → G8 sequential LIVE flip per strategy
                       ↓
                 G9 post-flip 24h monitoring
```

## G1 — rc-tag

```bash
# Working tree clean + suite green + HFV-EQUIV-style invariants pass
git tag -a v<version>-rc<N> -m "<scope summary>"
git push origin v<version>-rc<N>

# Verify on GitHub UI
gh release view v<version>-rc<N>
```

Acceptance:
- [ ] Tag exists on origin
- [ ] CHANGELOG entry references this tag
- [ ] All pre-tag commits explicitly listed in tag message

## G2 — Stage 0 sanity

Operator (or operator-named role) runs from production-like environment:

```bash
# 1. Repo state
git status --short             # empty
git log -1 --format='%h %s'    # matches expected rc-tag commit

# 2. Suite
<test_runner>                  # all pass

# 3. Critical invariants
<HFV-EQUIV-style gate>         # all green

# 4. Resource confirmation re-run (S2 might be stale)
<smoke-test-prod-creds>
<smoke-test-prod-daemons>
<smoke-test-prod-db>
```

Any RED → STOP. Do NOT proceed to G3.

## G3 — Operator decisions signed

Real precedent: AIOT v15.5 operator-decisions-2026-05-18.md v2 with 47
answer fields across strategy×account matrix.

```bash
# Operator types answers (NEVER AI-typed)
# Operator generates baseline hash
sha256sum docs/audits/.../operator-decisions.md
# Operator commits with GPG sign
git commit -S -m "docs(operator-decisions): N answers + sign-offs"
git push origin main
```

Acceptance:
- [ ] All answer fields filled (no `_______________`)
- [ ] All risk acknowledgements typed (no blank `accept/reject`)
- [ ] Baseline SHA256 saved to `/etc/<vault>/decisions-baseline.sha256`
- [ ] Commit GPG-signed (`git verify-commit HEAD` returns 0)

## G4 — Calibration ±tolerance

If implementation has upstream reference / spec calibration:

```bash
# Run calibration tool
<calibration-tool> --strategy <name> --from <date> --to <date>

# Verify metrics within tolerance:
#   PnL drift ≤ ±X%  (per spec)
#   Trade count parity (±1 trade per 20)
#   Critical paths same fire timing
```

Acceptance:
- [ ] All strategies within tolerance OR operator-typed risk acceptance
- [ ] Calibration output committed to `docs/audits/calibration-<date>.md`

## G5 — 24h soak SOAK-COMPLETE

Monitor production-equivalent environment for 24h continuous:

```bash
# Continuous monitor (cron + stamp-file pattern)
# This script is PROJECT-IMPLEMENTED. Reference structure below.
# Real precedent: AIOT v15.5 used tools/v15_phase1_soak_monitor.sh in
# AIOTMM/agent-5.2-binance-perp; structure was 5-check poll loop hitting:
#   1. Critical-invariants gate (HFV-EQUIV)
#   2. Test suite green
#   3. Working tree clean
#   4. Commit hash unchanged since soak start
#   5. Resource health green (daemons / API status)
bash <your-soak-monitor> --watch 300 --hours 24
# Expected: 5 checks GREEN every poll
```

Acceptance:
- [ ] 24h elapsed continuous
- [ ] Zero RED polls
- [ ] Final exit code 0 (SOAK-COMPLETE)

Any RED → HALT, RCA, fix, restart 24h clock.

## G6 — Paper-week green

Run feature in PAPER mode (no real money / no real production side-effects)
for 7 days:

```bash
# Day 1-7 daily check:
<feature-status-report> --window 24h
# Required:
#   100% API success (no 401, no -1, no 5xx)
#   N transactions matching expected baseline
#   0 persistence_error events
#   0 RED alarms
```

Acceptance per day:
- [ ] All daily checks green
- [ ] Any single day RED → reset counter to Day 1

Acceptance Day 7:
- [ ] All 7 days passed
- [ ] Realized result ≈ shadow baseline ± tolerance
- [ ] Operator-typed acknowledgement of any drift

## G7 — Flip-script with dual-path authentication

NEVER manual SQL. ALWAYS scripted with 9 gates of its own (real precedent:
`executor_live_flip.py` from AIOT Sprint-P):

```python
GATES = [
    "gate_0_db_backup_fresh",      # ≤ 60s old backup exists
    "gate_1_phrase_match",          # operator phrase exact match
    "gate_2_api_health",            # last 1h: 0×-1, 0×401, 100%×200
    "gate_3_soak_fresh",            # stamp file < 90min
    "gate_4_paper_window_green",    # 7-day paper green
    "gate_5_decisions_verified",    # dual-path: git verify-commit + sha256
    "gate_6_p1_items_closed",       # all P1 issues closed OR risk-accepted
    "gate_7_flip_atomic",           # atomic SQL txn
    "gate_8_telegram_alert",        # multi-tier alarm
    "gate_9_audit_log",             # state_change_events row written
]
```

Gate 5 dual-path (real precedent):
```python
# Path A: git verify-commit HEAD --raw   (author identity)
# Path B: sha256(decisions_path) == baseline_path content   (content fidelity)
# BOTH must pass. Either alone is bypassable.
```

Acceptance:
- [ ] Flip script committed + tested
- [ ] Each gate testable in isolation (mock-driven tests)
- [ ] Full happy-path test green
- [ ] Each gate FAIL → script refuses with stderr `[FLIP-REFUSED] gate-N: <reason>`
- [ ] Runbook updated to use script (replace any manual SQL)
- [ ] Companion `<feature>_revert.py` planned (post-flip emergency)

## G8 — Sequential LIVE flip per feature

NEVER flip all features at once. Sequence:

```
Day N:   Feature 1 LIVE   (smallest blast radius)
Day N+7: Feature 2 LIVE   (after Feature 1 stable)
Day N+14: Feature 3 LIVE  (after Feature 2 stable)
```

Each flip:
```bash
docker exec <container> python3 /app/bin/<flip-script> \
    --feature-uuid <from-register-step> \
    --confirm-phrase "<typed-by-operator>"
# Script runs all 9 internal gates; on green, atomic flip + alert + audit
```

Acceptance per flip:
- [ ] Script exit 0
- [ ] DB shows `mode='live'`
- [ ] Telegram tier-1+2+3 alert fired
- [ ] state_change_events row written
- [ ] First live transaction within expected window

## G9 — Post-flip 24h monitoring

```bash
# 1h after flip
<feature-health-check>
# 6h after
<feature-health-check>
# 24h after
<feature-health-check>
```

Required:
- [ ] No RED alarms
- [ ] First N transactions match paper-week baseline ± tolerance
- [ ] No `persistence_error` events
- [ ] Operator manually verified UX once

Any RED → consider revert (G7 companion script).

## Rollback path (G7 revert companion)

Every flip-script needs a paired revert:

```bash
docker exec <container> python3 /app/bin/<feature>_paper_revert.py \
    --feature-uuid <uuid> \
    --revert-phrase "<different from flip phrase>"
# 4-gate revert protocol:
#   1. Phrase match
#   2. Tier-1 alarm fired ("revert in progress")
#   3. Atomic UPDATE mode='paper' + audit row
#   4. Confirm callback
```

## Anti-patterns

- **Skipping G5 soak** — production loads not the same as test loads
- **Combining G7+G8 in one script run** — operator needs explicit go between
- **Manual SQL flip** — no audit, no rollback, no operator phrase
- **"It worked in paper, just go live"** — paper is not production
- **Skipping G9 post-flip monitoring** — bugs surface in first 24h

## Time budget

| Gate | Duration |
|---|---|
| G1 | 5 min |
| G2 | 15 min |
| G3 | 30-45 min (operator-typed) |
| G4 | 30-60 min |
| G5 | 24h passive |
| G6 | 7 days passive |
| G7 | 4-11h (authoring) |
| G8 | 5 min per feature (script run) |
| G9 | 24h passive |

**Total minimum**: ~10 days for first flip (24h soak + 7 paper days + 1 day flip + 24h watch).

## Self-validate

- [ ] No gate skipped
- [ ] Each gate has documented acceptance
- [ ] Operator-only steps are operator-typed (NEVER AI-typed)
- [ ] Flip script + revert companion both exist
- [ ] Runbook reflects gated sequence
- [ ] Post-flip monitoring continues for full 24h before declaring "done"
